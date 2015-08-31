class RunDecorator < Draper::Decorator
  delegate_all
  decorates_association :runner

  def duration_formatted
    h.format_duration(object.duration)
  end
end
