class Run < ActiveRecord::Base
  belongs_to :runner, counter_cache: true
  belongs_to :category
  belongs_to :run_day

  def mean_duration_for_run_day_category
    Run.where(category_id: category_id, run_day_id: run_day_id).average(:duration)
  end
end
