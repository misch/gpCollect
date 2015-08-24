class Runner < ActiveRecord::Base
  has_many :runs
  has_many :categories, through: :runs
  has_many :run_days, through: :runs
end
