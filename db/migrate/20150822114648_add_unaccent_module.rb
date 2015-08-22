class AddUnaccentModule < ActiveRecord::Migration
  def up
    # Needs this installed: sudo apt-get install postgresql-contrib
    execute 'CREATE EXTENSION unaccent;'
  end
end
