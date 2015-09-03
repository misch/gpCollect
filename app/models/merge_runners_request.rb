class MergeRunnersRequest < ActiveRecord::Base
  has_and_belongs_to_many :runners

  INHERITED_ATTRIBUTES = [:first_name, :last_name, :nationality, :sex, :club_or_hometown]
  def self.new_from(merge_candidates)
    # Select most runner with most recent run as default for attributes of merge requests.
    best_mc = merge_candidates.max_by {|mc| mc.run_days.max_by(&:date) }
    merge_request_defaults = INHERITED_ATTRIBUTES.each_with_object({}) {|attr, hash| hash["merged_#{attr}"] = best_mc[attr]}
    self.new(merge_request_defaults)
  end
end
