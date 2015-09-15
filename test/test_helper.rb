ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  include Devise::TestHelpers
  # Add more helper methods to be used by all tests here...

  def setup
    FactoryGirl.create(:admin)
  end

  def teardown
    Admin.delete_all
  end
end