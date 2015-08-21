class AddIndexToRunner < ActiveRecord::Migration
  def change
    add_index :runners, :last_name
  end
end
