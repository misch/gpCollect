require 'test_helper'

class RunnersControllerTest < ActionController::TestCase
  setup do
    @runner = create(:runner_with_runs)
    # Create run aggregates that are needed for show action.
    Rake::Task['db:create_run_aggregates'].invoke
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should show runner" do
    get :show, id: @runner
    assert_response :success
  end
end
