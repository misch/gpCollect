class RunnerDecorator < Draper::Decorator
  delegate_all
  decorates_association :runs

end
