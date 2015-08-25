require_relative 'seed_helpers'
require_relative 'merge_runners_helpers'

ActiveRecord::Base.logger = Logger.new File.open('log/development.log', 'a')

[Run, RunDay, Runner, Category, Route, Organizer].each do |model|
  model.delete_all
  ActiveRecord::Base.connection.reset_pk_sequence!(model.table_name)
end

route_16km = Route.create!(length: 16.093)
gp_bern_organizer = Organizer.create!(name: "Grand Prix von Bern")

files = [{file: "db/data/gp_bern_10m_2013.csv",
          run_day: RunDay.create!(organizer: gp_bern_organizer, date: Date.new(2013, 5, 18), route: route_16km)},
         {file: "db/data/gp_bern_10m_2014.csv",
          run_day: RunDay.create!(organizer: gp_bern_organizer, date: Date.new(2014, 5, 10), route: route_16km)},
         {file: "db/data/gp_bern_10m_2015.csv",
          run_day: RunDay.create!(organizer: gp_bern_organizer, date: Date.new(2015, 5, 9), route: route_16km)}]
files.each { |file| SeedHelpers::seed_runs_file file }

MergeRunnersHelpers::merge_duplicates