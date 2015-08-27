class RunDecorator < Draper::Decorator
  delegate_all

  def duration_formatted
    return 'disqualified' if object.duration.nil?
    hours = object.duration / 3600 / 1000
    minutes = (object.duration % (3600 * 1000)) / 60 / 1000
    seconds = (object.duration % (60 * 1000)).to_f / 1000
    '%02d:%02d:%04.1f'  % [hours, minutes, seconds]
  end

  def runner_name
   "#{object.runner.first_name} #{run.runner.last_name}"
  end
end
