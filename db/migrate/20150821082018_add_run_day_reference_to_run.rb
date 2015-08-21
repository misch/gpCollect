class AddRunDayReferenceToRun < ActiveRecord::Migration
  def change
    add_reference :runs, :run_day, index: true, foreign_key: true
  end
end
