class Runner < ActiveRecord::Base
  # TODO: use run_day.date for ordering, seems to be tough to do since it needs another join.
  has_many :runs, -> { order(run_day_id: :asc) }
  has_many :categories, through: :runs
  has_many :run_days, through: :runs

  def fastest_run
    runs.min_by { |i| i.duration || 0 }
  end
end
