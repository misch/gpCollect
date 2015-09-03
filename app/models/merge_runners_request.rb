class MergeRunnersRequest < ActiveRecord::Base
  has_and_belongs_to_many :runners
end
