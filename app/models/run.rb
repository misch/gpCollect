class Run < ActiveRecord::Base
  belongs_to :runner
  belongs_to :category
end
