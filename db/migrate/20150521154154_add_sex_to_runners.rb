class AddSexToRunners < ActiveRecord::Migration
  def change
    add_column :runners, :sex, :string
  end
end
