class RunDayCategoryAggregate < ActiveRecord::Base
  self.primary_keys = :run_day_id, :category_id
  belongs_to :run_day
  belongs_to :category
  has_many :runs, class_name: 'Run', :foreign_key => [:run_day_id, :category_id]

  before_save :update_aggregate_attributes

  def update_aggregate_attributes
    # self.runs somehow does not work until record is saved.
    aggregated_runs = Run.where(run_day: run_day, category: category)
    self.mean_duration = aggregated_runs.average(:duration)
    self.runs_count = aggregated_runs.count
  end
end
