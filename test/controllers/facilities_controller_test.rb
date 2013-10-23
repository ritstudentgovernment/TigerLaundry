require 'test_helper'

class FacilitiesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @facility     = facilities(:one)
    @admin_user   = users(:admin)
    @mod_user     = users(:mod)
    @regular_user = users(:regular)
  end

  test "should get index" do
    sign_in @regular_user
    get :index
    assert_response :success
    assert_not_nil assigns(:facilities)
  end

  test "should get new" do
    sign_in @admin_user
    get :new
    assert_response :success
  end

  test "should create facility" do
    sign_in @admin_user
    assert_difference('Facility.count') do
      post :create, facility: { driers: @facility.driers,
                                name: @facility.name,
                                washers: @facility.washers }
    end

    assert_redirected_to facility_path(assigns(:facility))
  end

  test "should show facility" do
    get :show, id: @facility
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin_user
    get :edit, id: @facility
    assert_response :success
  end

  test "should update facility" do
    sign_in @admin_user
    patch :update, id: @facility, facility: { driers: @facility.driers,
                                              name: @facility.name,
                                              washers: @facility.washers }
    assert_redirected_to facility_path(assigns(:facility))
  end

  test "should destroy facility" do
    sign_in @admin_user
    assert_difference('Facility.count', -1) do
      delete :destroy, id: @facility
    end

    assert_redirected_to facilities_path
  end
end
