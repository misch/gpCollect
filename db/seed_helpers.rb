require 'csv'
module SeedHelpers
  # TODO: Possibly handle disqualified cases better.
  # Right now they have nil as duration (but still have an entry in the run table).
  def self.duration_string_to_milliseconds(duration_string)
    if duration_string == 'DSQ'
      nil
    else
      duration_array = duration_string.split(':').map(&:to_f)
      ((duration_array[0] * 3600 + duration_array[1] * 60 + duration_array[2]) * 1000).to_i
    end
  end

  CATEGORIES = {}
  # Finds category with some memoization.
  def self.find_or_create_category_for(category_string)
    if CATEGORIES[category_string]
      CATEGORIES[category_string]
    else
      category_hash = {}
      category_string.match /([MW])U?(\d{1,3})/ do |matches|
        category_hash[:sex] = matches[1]
        if category_string[1] == 'U'
          category_hash[:age_max] = matches[2].to_i
        else
          category_hash[:age_min] = matches[2].to_i
        end
      end
      category = Category.find_or_create_by!(category_hash)
      CATEGORIES[category_string] = category
      category
    end
  end

  def self.find_or_create_runner_for(runner_hash, run_day, category)
    # only possible matches are runners that match all attribute and don't have a run already registered on that day.
    possible_matches = Runner.includes(:run_days).where(runner_hash).where('run_days.id != ?', run_day.id).references(:run_days)
    estimated_birth_date = run_day.date - (category.age_max || category.age_min).years
    # Check which runner is closest in birth date
    closest_birth_date_diff, closest_birth_date_idx =
        possible_matches.map { |r| (r.birth_date - estimated_birth_date).abs }.each_with_index.min
    # TODO: Don't only use age for finding closest match, but also duration of run vs average duration of runs.
    runner = if closest_birth_date_diff and closest_birth_date_diff < 10 * 365
               possible_matches[closest_birth_date_idx]
             else
               Runner.new(runner_hash.merge(birth_date: estimated_birth_date))
             end
    if category.age_max and runner.birth_date < estimated_birth_date
      # Estimated age is a lower bound here, update to it if higher than previous estimate.
      runner.birth_date = estimated_birth_date
    elsif category.age_min and runner.birth_date > estimated_birth_date
      # Estimated age is an upper bound here, update to it if lower than previous estimate.
      runner.birth_date = estimated_birth_date
    end
    runner.save!
    runner
  end

  NAME_REGEXP = /(?<last_name>[^,]*), (?<first_name>[^(]+?) ?(?:\((?<nationality>[A-Z]*)\))?$/

  # Seeds a file with the given options. Options are expected to have the following keys:
  # * file: The file to be seeded
  # * run_day: The run day the runs to be seeded belong to
  #
  # Optionally taking the following keys:
  # * shift: Additional shift of read out columns, if format does not match exactly.
  def self.seed_runs_file(options)
    file = options.fetch(:file)
    shift = options.fetch(:shift, 0)
    puts "Seeding #{file} "
    progressbar = ProgressBar.create(total: `wc -l #{file}`.to_i, format: '%B %R runs/s, %a',
                                     :throttle_rate => 0.1)
    run_day = options.fetch(:run_day)
    ActiveRecord::Base.transaction do
      CSV.open(file, headers: true, col_sep: ';').each do |line|
        runner_hash = {}
        name = line[4 + shift]
        category_string = line[5 + shift]
        runner_hash[:club_or_hometown] = line[6 + shift]
        duration_string = line[10 + shift]
        begin
          # E. g. 'Abati, Mauro (SUI)'
          m = NAME_REGEXP.match name
          if m
            runner_hash[:last_name] = m[:last_name]
            runner_hash[:first_name] = m[:first_name]
            runner_hash[:nationality] = m[:nationality]
          else
            # Known issue: in 2013 file there are some names that only consist of nationality, skip these
            if name.match /\([A-Z]{3}\)/
              next
            else
              raise 'Could not parse name: ' + name
            end
          end

          # Don't create a runner/run if there is no category or duration associated.
          next if category_string.blank? or duration_string.blank?
          category = find_or_create_category_for(category_string)
          runner_hash[:sex] = category.sex

          runner = find_or_create_runner_for(runner_hash, run_day, category)

          # TODO: Somehow handle this over multiple years (allow change of hometown)
          #runner.update_attributes!(club_or_hometown: club_or_hometown)
          # TODO: think of something to handle intermediary times.
          Run.create!(runner: runner, category: category, duration: duration_string_to_milliseconds(duration_string),
                      run_day: run_day)
          progressbar.increment
        rescue Exception => e
          puts "Failed parsing: #{line}"
          raise e
        end
      end
    end
    progressbar.finish
  end
end
