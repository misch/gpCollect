require 'csv'

# TODO: Possibly handle disqualified cases better.
# Right now they have nil as duration (but still have an entry in the run table).
def duration_string_to_milliseconds(duration_string)
  if duration_string == 'DSQ'
    nil
  else
    duration_array = duration_string.split(':').map(&:to_f)
    ((duration_array[0] * 3600 + duration_array[1] * 60 + duration_array[2]) * 1000).to_i
  end
end

NAME_REGEXP = /(?<last_name>[^,]*), (?<first_name>[^(]+?) ?(?:\((?<nationality>[A-Z]*)\))?$/

def seed_runs_file(options)
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

        category = category_hash.blank? ? nil : Category.find_or_create_by!(category_hash)
        runner_hash[:sex] = category_hash[:sex]
        runner = Runner.find_or_create_by!(runner_hash)
        # TODO: Somehow handle this over multiple years (allow change of hometown)
        #runner.update_attributes!(club_or_hometown: club_or_hometown)
        duration_string = line[10]
        # TODO: think of something to handle intermediary times.
        unless duration_string.blank?
          Run.create!(runner: runner, category: category, duration: duration_string_to_milliseconds(duration_string),
                      run_day: run_day)
        end
        progressbar.increment
      rescue Exception => e
        puts "Failed parsing: #{line}"
        raise e
      end
    end
  end
  progressbar.finish
end

MALE_FIRST_NAMES = %w(Jannick)
FEMALE_FIRST_NAMES = %w()

def merge_duplicates
  identifying_runner_attributes = [:first_name, :last_name, :nationality, :club_or_hometown, :sex]

  # Handle wrong sex (if more are found)
  only_differing_sex = Runner.select(identifying_runner_attributes - [:sex])
                           .group(identifying_runner_attributes - [:sex]).having('count(*) > 1')
  only_differing_sex.each do |r|
    correct_sex = if MALE_FIRST_NAMES.include?(r.first_name)
                    'M'
                  elsif FEMALE_FIRST_NAMES.include?(r.first_name)
                    'W'
                  else
                    raise "Could not match gender to #{r}, please extend names list."
                  end
    correct_entry = Runner.where(sex: correct_sex).find_by!(r.serializable_hash.except('id'))
    incorrect_entry = Runner.where.not(sex: correct_sex).find_by!(r.serializable_hash.except('id'))
    correct_entry.runs += incorrect_entry.runs
    correct_entry.save!
    incorrect_entry.destroy!
  end

  # TODO: try to fix wrongly written names, e. g.
  # Abdel	Mâarouf	Bern	M
  # Abdel	Maarouf	Bern	M
  only_differing_first_name_accents = Runner.select(identifying_runner_attributes - [:first_name] + ["unaccent(first_name) as unaccent_first_name"]).group(identifying_runner_attributes - [:first_name] + ['unaccent_first_name']).having('count(*) > 1')
  # TODO: try to fix club_or_hometown duplicates, e. g.
  # Achim	Seifermann	LAUFWELT de Lauftreff
  # Achim	Seifermann	Laufwelt.de
  #only_differing_club_or_hometown = Runner.select(identifying_runner_attributes - [:club_or_hometown])
  #                                      .group(identifying_runner_attributes - [:club_or_hometown]).having('count(*) > 1')
end
