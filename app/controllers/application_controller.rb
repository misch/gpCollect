class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action do
    # If logged in, show rack profiler stats.
    if admin_signed_in?
      Rack::MiniProfiler.authorize_request
    end
  end
end
