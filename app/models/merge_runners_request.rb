class MergeRunnersRequest < ActiveRecord::Base
  has_and_belongs_to_many :runners
  has_many :runs, through: :runners

  INHERITED_ATTRIBUTES = [:first_name, :last_name, :nationality, :sex, :club_or_hometown, :birth_date]
  def self.new_from(merge_candidates)
    # Select most runner with most recent run as default for attributes of merge requests.
    best_mc = merge_candidates.max_by {|mc| mc.run_days.max_by(&:date) }
    # TODO: possibly do something more sophisticated with birth_date.
    merge_request_defaults = INHERITED_ATTRIBUTES.each_with_object({}) {|attr, hash| hash["merged_#{attr}"] = best_mc[attr]}
    merge_request_defaults[:runners] = merge_candidates
    self.new(merge_request_defaults)
  end

  # Instantiates a new runner with data from this merge request and associates all runs with the new instance. Still
  # needs to be saved in order to be written to DB!
  def to_new_runner
    runner_attributes = INHERITED_ATTRIBUTES.each_with_object({}) {|attr, hash| hash[attr] = self["merged_#{attr}"]}
    runner_attributes[:runs] = runs
    Runner.new(runner_attributes)
  end
end
