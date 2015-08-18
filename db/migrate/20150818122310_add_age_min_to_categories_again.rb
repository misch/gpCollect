class AddAgeMinToCategoriesAgain < ActiveRecord::Migration
  def change
    add_column :categories, :age_max, :integer
  end
end
