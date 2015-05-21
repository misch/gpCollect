class CreateRunners < ActiveRecord::Migration
  def change
    create_table :runners do |t|
      t.string :first_name
      t.string :last_name
      t.date :birth_date

      t.timestamps null: false
    end
  end
end
