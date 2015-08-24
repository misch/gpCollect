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

def find_or_create_runner_for(runner_hash, estimated_birth_date)
  possible_matches = Runner.where(runner_hash)
  # Check which runner is closest in birth date
  closest_birth_date_diff, closest_birth_date_idx =
      possible_matches.map {|r| (r.birth_date - estimated_birth_date).abs }.each_with_index.min
  if closest_birth_date_diff and closest_birth_date_diff < 10 * 365
    possible_matches[closest_birth_date_idx]
  else
    Runner.create!(runner_hash.merge(birth_date: estimated_birth_date))
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
        # Don't create a runner/run if there is no category associated.
        next if category_hash.blank?
        category = Category.find_or_create_by!(category_hash)
        runner_hash[:sex] = category_hash[:sex]
        estimated_birth_date = run_day.date - (category.age_max || category.age_min).years
        runner = find_or_create_runner_for(runner_hash, estimated_birth_date)


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

def merge_runners(runner, to_be_merged_runner)
  runner.runs += to_be_merged_runner.runs
  runner.save!
  to_be_merged_runner.destroy!
end

def find_runners_only_differing_in(attr, additional_attributes_select=[], additional_attributes_group=[])
  identifying_runner_attributes_select = [:first_name, :last_name, :nationality, :club_or_hometown, :sex, '(current_date - birth_date)/365/10 AS age']
  identifying_runner_attributes_group = [:first_name, :last_name, :nationality, :club_or_hometown, :sex, 'age']
  r = Runner.select(identifying_runner_attributes_select - [attr] + additional_attributes_select + ['array_agg(id) AS ids'])
          .group(identifying_runner_attributes_group - [attr] + additional_attributes_group).having('count(*) > 1')
  r.map {|i| Runner.find(i['ids']) }
end

MALE_FIRST_NAMES = %w(Jannick)
FEMALE_FIRST_NAMES = %w()
POSSIBLY_WRONGLY_ACCENTED_ATTRIBUTES = [:first_name, :last_name]
POSSIBLY_WRONGLY_CASED_ATTRIBUTES = [:club_or_hometown]
POSSIBLY_WRONGLY_SPACED_ATTRIBUTES = [:first_name, :last_name, :club_or_hometown]

def merge_duplicates
  # Handle wrong sex, try to find correct correct sex using name list.
  find_runners_only_differing_in(:sex).each do |entries|
    if entries.size != 2
      raise 'More than two possibilities, dont know what to do!'
    end
    # These are differentiated by age, go to next.
    next if (entries.first.birth_date - entries.second.birth_date).abs > 10 * 365
    first_name = entries.first.first_name
    correct_entry, wrong_entry = if MALE_FIRST_NAMES.include?(first_name)
                                   # M comes first, so ordering by sex will return it first.
                                   entries.sort_by(&:sex)
                                 elsif FEMALE_FIRST_NAMES.include?(first_name)
                                   entries.sort_by(&:sex).reverse
                                 else
                                   raise "Could not match gender to #{entries}, please extend names list."
                                 end
    merge_runners(correct_entry, wrong_entry)
  end

  POSSIBLY_WRONGLY_ACCENTED_ATTRIBUTES.each do |attr|
    merged_runners = 0
    find_runners_only_differing_in(attr, ["f_unaccent(#{attr}) as unaccented"], ['unaccented']).each_with_index do |entries|
      if entries.size != 2
        raise 'More than two possibilities, dont know what to do!'
      end
      # The correct entry is the one with accents (most probably?),
      # so the one that is not equal to it's transliterated version.
      correct_entry, wrong_entry = if entries.first[attr] == ActiveSupport::Inflector.transliterate(entries.first[attr])
                                     [entries.second, entries.first]
                                   elsif entries.second[attr] == ActiveSupport::Inflector.transliterate(entries.second[attr])
                                     [entries.first, entries.second]
                                   else
                                     raise "Couldnt find correct entry for #{entries}"
                                   end
      merge_runners(correct_entry, wrong_entry)
      merged_runners += 1
    end
    puts "Merged #{merged_runners} entries based on accents of #{attr}."
  end


  # Try to fix case sensitive duplicates in club_or_hometown, e. g. in
  # Veronique	Plessis	Arc Et Senans
  # Veronique	Plessis	Arc et Senans
  POSSIBLY_WRONGLY_CASED_ATTRIBUTES.each do |attr|
    merged_runners = 0
    find_runners_only_differing_in(attr, ["f_unaccent(lower(#{attr})) as low"], ['low']).each do |entries|
      if entries.size != 2
        raise 'More than two possibilities, dont know what to do!'
      end
      # We take the one with more lowercase characters as he correct one. E. g. for
      # Reichenbach I. K.
      # Reichenbach i. K.
      # the version at the bottom is preferred.
      correct_entry, wrong_entry = if entries.first[attr].scan(/[[:lower:]]/).size > entries.second[attr].scan(/[[:lower:]]/).size
                                     [entries.first, entries.second]
                                   else
                                     [entries.second, entries.first]
                                   end
      merge_runners(correct_entry, wrong_entry)
      merged_runners += 1
    end
    puts "Merged #{merged_runners} entries based on case of #{attr}."
  end

  POSSIBLY_WRONGLY_SPACED_ATTRIBUTES.each do |attr|
    merged_runners = 0
    find_runners_only_differing_in(attr, ["replace(#{attr}, '-', ' ') as spaced"], ['spaced']).each do |entries|
      if entries.size != 2
        raise 'More than two possibilities, dont know what to do!'
      end
      # We take the one with more spaces as he correct one.
      correct_entry, wrong_entry = if entries.first[attr].scan(/ /).size > entries.second[attr].scan(/ /).size
                                     [entries.first, entries.second]
                                   else
                                     [entries.second, entries.first]
                                   end
      merge_runners(correct_entry, wrong_entry)
      merged_runners += 1
    end
    puts "Merged #{merged_runners} entries based on spaces of #{attr}."
  end

  # TODO: Try to fix club_or_hometown duplicates, e. g.
  # Achim	Seifermann	LAUFWELT de Lauftreff
  # Achim	Seifermann	Laufwelt.de
  #only_differing_club_or_hometown = Runner.select(identifying_runner_attributes - [:club_or_hometown])
  #                                      .group(identifying_runner_attributes - [:club_or_hometown]).having('count(*) > 1')
end
