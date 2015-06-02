class Runner < ActiveRecord::Base
  has_many :runs

  def earliest_run
    runs.order(start: :asc).limit(1).first
  end
end
