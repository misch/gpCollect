class Runner < ActiveRecord::Base
  has_many :runs
  has_many :categories, through: :runs
end
