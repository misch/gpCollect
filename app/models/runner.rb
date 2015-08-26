class Runner < ActiveRecord::Base
  has_many :runs
  has_many :categories, through: :runs
  has_many :run_days, through: :runs

  def fastest_run
    runs.min_by &:duration
  end
end
