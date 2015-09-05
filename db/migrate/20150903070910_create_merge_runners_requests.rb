class CreateMergeRunnersRequests < ActiveRecord::Migration
  def change
    create_table :merge_runners_requests do |t|
      t.string :merged_first_name
      t.string :merged_last_name
      t.string :merged_club_or_hometown
      t.string :merged_nationality
      t.string :merged_sex

      t.timestamps null: false
    end
    create_join_table :runners, :merge_runners_requests
  end
end
