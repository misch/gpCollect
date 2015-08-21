# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'csv'

def duration_string_to_milliseconds(duration_string)
  duration_array = duration_string.split(':').map(&:to_f)
  ((duration_array[0] * 3600 + duration_array[1] * 60 + duration_array[2]) * 1000).to_i
end

def seed_runs_file(options)
  puts "Seed " + options.fetch(:file)
  progressbar = ProgressBar.create(total: `wc -l #{file}`.to_i)
  ActiveRecord::Base.transaction do
    CSV.open(file, headers: true, col_sep: ';').each do |line|
      category_hash = {}
      runner_hash = {}
      name = line[4]
      category_string = line[5]
      runner_hash[:club_or_hometown] = line[6]
      begin
        # E. g. 'Abati, Mauro (SUI)'
        m = name.match /([^,]*), ([^(]*) \(([A-Z]*)\)/ do |matches|
          runner_hash[:last_name] = matches[1]
          runner_hash[:first_name] = matches[2]
          runner_hash[:nationality] = matches[3]
        end
        raise 'Did not match!' unless m

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
      rescue Exception => e
        puts "Failed parsing: #{line}"
        raise e
      end

      category = category_hash.blank? ? nil : Category.find_or_create_by!(category_hash)
      runner_hash[:sex] = category_hash[:sex]
      runner = Runner.find_or_create_by!(runner_hash)
      # TODO: Somehow handle this over multiple years (allow change of hometown)
      #runner.update_attributes!(club_or_hometown: club_or_hometown)
      duration_string = line[10]
      # TODO: think of something to handle intermediary times.
      unless duration_string.blank?
        Run.create!(runner: runner, category: category, duration: duration_string_to_milliseconds(duration_string), run_day: options.fetch(:run_day))
      end
      progressbar.increment
    end
  end
  progressbar.finish
end


Run.delete_all
RunDay.delete_all
Runner.delete_all
Category.delete_all
Route.delete_all
Organizer.delete_all

route_16km = Route.create!(length: 16.093)
gp_bern_organizer = Organizer.create!(name: "Grand Prix von Bern")
run_day_gp_2015_16km = RunDay.create!(organizer: gp_bern_organizer, date: Date.new(2015, 5, 9), weather: "dunno", route: route_16km)

files = [{file: "db/data/gp_bern_10m_2015.csv", run_day: run_day_gp_2015_16km}]
files.each { |file| seed_runs_file file }

puts "All files seeded."
