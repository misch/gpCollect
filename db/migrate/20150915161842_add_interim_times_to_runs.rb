class AddInterimTimesToRuns < ActiveRecord::Migration
  def change
    add_column :runs, :interim_times, :integer, array: true
  end
end
