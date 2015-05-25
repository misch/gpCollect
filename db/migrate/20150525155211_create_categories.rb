class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :sex
      t.integer :age

      t.timestamps null: false
    end
  end
end
