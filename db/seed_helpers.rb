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

  def self.find_or_create_runner_for(runner_hash, run_day, category)
    # only possible matches are runners that match all attribute and don't have a run already registered on that day.
    possible_matches = Runner.includes(:run_days).where(runner_hash).where.not(run_days: {id: run_day.id})
    estimated_birth_date = run_day.date - (category.age_max || category.age_min).years
    # Check which runner is closest in birth date
    closest_birth_date_diff, closest_birth_date_idx =
        possible_matches.map { |r| (r.birth_date - estimated_birth_date).abs }.each_with_index.min
    runner = if closest_birth_date_diff and closest_birth_date_diff < 10 * 365
               possible_matches[closest_birth_date_idx]
             else
               Runner.new(runner_hash.merge(birth_date: estimated_birth_date))
             end
    if category.age_max and runner.birth_date < estimated_birth_date
      # Estimated age is a lower bound here, update to it is higher than previous estimate.
      runner.birth_date = estimated_birth_date
    elsif category.age_min and runner.birth_date > estimated_birth_date
      # Estimated age is an upper bound here, update to it is lower than previous estimate.
      runner.birth_date = estimated_birth_date
    end
    runner.save!
    runner
  end

  NAME_REGEXP = /(?<last_name>[^,]*), (?<first_name>[^(]+?) ?(?:\((?<nationality>[A-Z]*)\))?$/

  def self.seed_runs_file(options)
    file = options.fetch(:file)
    puts "Seeding #{file} "
    progressbar = ProgressBar.create(total: `wc -l #{file}`.to_i, format: '%B %R runs/s, %a',
                                     :throttle_rate => 0.1)
    run_day = options.fetch(:run_day)
    ActiveRecord::Base.transaction do
      CSV.open(file, headers: true, col_sep: ';').each do |line|
        category_hash = {}
        runner_hash = {}
        name = line[4]
        category_string = line[5]
        runner_hash[:club_or_hometown] = line[6]
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
              raise 'Did not match!'
            end
          end

          unless category_string.blank?
            category_string.match /([MW])U?(\d{1,3})/ do |matches|
              category_hash[:sex] = matches[1]
              if category_string[1] == 'U'
                category_hash[:age_max] = matches[2].to_i
              else
                category_hash[:age_min] = matches[2].to_i
              end
            end
          end
          duration_string = line[10]
          # Don't create a runner/run if there is no category or duration associated.
          next if category_hash.blank? or duration_string.blank?
          
          category = Category.find_or_create_by!(category_hash)
          runner_hash[:sex] = category_hash[:sex]

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
