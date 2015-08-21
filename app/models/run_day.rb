class RunDay < ActiveRecord::Base
  belongs_to :organizer
  belongs_to :route
  has_many :runs
end
