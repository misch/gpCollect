class AddRunCountCacheToRunners < ActiveRecord::Migration
  def change
    add_column :runners, :runs_count, :integer, default: 0
  end
end
