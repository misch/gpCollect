class AddUnaccentModule < ActiveRecord::Migration
  def up
    # Needs this installed: sudo apt-get install postgresql-contrib
    enable_extension :unaccent
  end
end
