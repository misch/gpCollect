require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase
  setup do
    @category = create(:category)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:categories)
  end

  test "should show category" do
    get :show, id: @category
    assert_response :success
  end
end
