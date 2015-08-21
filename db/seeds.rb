require 'seed_helpers'

Run.delete_all
RunDay.delete_all
Runner.delete_all
Category.delete_all
Route.delete_all
Organizer.delete_all


route_16km = Route.create!(length: 16.093)
gp_bern_organizer = Organizer.create!(name: "Grand Prix von Bern")

files = [{file: "db/data/gp_bern_10m_2013.csv",
          run_day: RunDay.create!(organizer: gp_bern_organizer, date: Date.new(2015, 5, 18), route: route_16km)},
         {file: "db/data/gp_bern_10m_2014.csv",
          run_day: RunDay.create!(organizer: gp_bern_organizer, date: Date.new(2015, 5, 10), route: route_16km)},
         {file: "db/data/gp_bern_10m_2015.csv",
          run_day: RunDay.create!(organizer: gp_bern_organizer, date: Date.new(2015, 5, 9), route: route_16km)}]
files.each { |file| seed_runs_file file }

