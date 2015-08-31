class RunnerDecorator < Draper::Decorator
  delegate_all
  decorates_association :runs

  def name
    "#{object.first_name} #{object.last_name}"
  end

  def mean_run_duration
    h.format_duration(object.mean_run_duration)
  end
end
