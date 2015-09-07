class MergeRunnersRequestDecorator < Draper::Decorator
  delegate_all

  def runners
    object.runners.map { |r| h.link_to r.id, r }.join(', ').html_safe
  end
end
