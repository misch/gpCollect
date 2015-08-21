class Run < ActiveRecord::Base
  belongs_to :runner
  belongs_to :category
  belongs_to :run_day
end
