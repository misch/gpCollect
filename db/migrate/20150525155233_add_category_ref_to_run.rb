class AddCategoryRefToRun < ActiveRecord::Migration
  def change
    add_reference :runs, :category, index: true, foreign_key: true
  end
end
