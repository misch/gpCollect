class AddIndexToRunners < ActiveRecord::Migration
  TEXT_SEARCH_ATTRIBUTES = %w(first_name last_name club_or_hometown)

  def change
    enable_extension :pg_trgm
    reversible do |dir|
      dir.up do
        execute "CREATE INDEX runners_last_name_pattern on runners(last_name varchar_pattern_ops)"
      end
      dir.down do
        remove_index :runners, name: 'runners_last_name_pattern'
      end
    end
    TEXT_SEARCH_ATTRIBUTES.each do |attr|
      reversible do |dir|
        dir.up do
          execute "CREATE INDEX runners_#{attr}_gin ON runners USING gin(#{attr} gin_trgm_ops)"
        end
        dir.down do
          remove_index :runners, name: "runners_#{attr}_gin"
        end
      end
    end
  end
end
