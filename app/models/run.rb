class Run < ActiveRecord::Base
  belongs_to :runner, counter_cache: true
  belongs_to :category
  belongs_to :run_day
  belongs_to :run_day_category_aggregate, :foreign_key => [:run_day_id, :category_id]
end
