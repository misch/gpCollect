require 'test_helper'

class RunnersControllerTest < ActionController::TestCase
  setup do
    @runner = runners(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:runners)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create runner" do
    assert_difference('Runner.count') do
      post :create, runner: { birth_date: @runner.birth_date, first_name: @runner.first_name, last_name: @runner.last_name }
    end

    assert_redirected_to runner_path(assigns(:runner))
  end

  test "should show runner" do
    get :show, id: @runner
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @runner
    assert_response :success
  end

  test "should update runner" do
    patch :update, id: @runner, runner: { birth_date: @runner.birth_date, first_name: @runner.first_name, last_name: @runner.last_name }
    assert_redirected_to runner_path(assigns(:runner))
  end

  test "should destroy runner" do
    assert_difference('Runner.count', -1) do
      delete :destroy, id: @runner
    end

    assert_redirected_to runners_path
  end
end
