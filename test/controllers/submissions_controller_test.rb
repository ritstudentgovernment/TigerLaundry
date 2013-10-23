require 'test_helper'

class SubmissionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @submission   = submissions(:one)
    @admin_user   = users(:admin)
    @mod_user     = users(:mod)
    @regular_user = users(:regular)
  end

  test "should get index" do
    sign_in @regular_user
    get :index, facility_id: @submission.facility_id
    assert_response :success
    assert_not_nil assigns(:submissions)
  end

  test "should get new" do
    sign_in @regular_user
    get :new, facility_id: @submission.facility_id
    assert_response :success
  end

  test "should create submission" do
    sign_in @regular_user
    assert_difference('Submission.count') do
      post :create,
           facility_id: @submission.facility_id,
           submission: { driers: @submission.driers,
                         facility_id: @submission.facility_id,
                         washers: @submission.washers }
    end

    assert_redirected_to facility_submission_path(assigns(:facility),
                                                  assigns(:submission))
  end

  test "should show submission" do
    sign_in @regular_user
    get :show, id: @submission, facility_id: @submission.facility_id
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin_user
    get :edit, id: @submission, facility_id: @submission.facility_id
    assert_response :success
  end

  test "should update submission" do
    sign_in @admin_user
    patch :update,
          id: @submission,
          facility_id: @submission.facility_id,
          submission: { driers: @submission.driers,
                        facility_id: @submission.facility_id,
                        washers: @submission.washers }
    assert_redirected_to facility_submission_path(assigns(:facility),
                                                  assigns(:submission))
  end

  test "should destroy submission" do
    sign_in @admin_user
    assert_difference('Submission.count', -1) do
      delete :destroy, id: @submission, facility_id: @submission.facility_id
    end

    assert_redirected_to facility_submissions_path(assigns(:facility))
  end

  test "should get limited" do
    sign_in @regular_user
    get :limited, facility_id: @submission.facility_id, format: :json
    assert_response :success
  end
end
