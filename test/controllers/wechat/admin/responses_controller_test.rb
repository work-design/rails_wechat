require 'test_helper'
class Wechat::Admin::ResponsesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @response = create :response
  end

  test 'index ok' do
    get admin_app_responses_url(@response.app)
    assert_response :success
  end

  test 'new ok' do
    get new_admin_app_response_url(@response.app), xhr: true
    assert_response :success
  end

  test 'create ok' do
    assert_difference('Response.count') do
      post admin_app_responses_url(@response.app), params: { response: { match_value: 'test' } }, xhr: true
    end

    assert_response :success
  end

  test 'show ok' do
    get admin_app_response_url(@response.app, @response), xhr: true
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_app_response_url(@response.app, @response), xhr: true
    assert_response :success
  end

  test 'update ok' do
    patch admin_app_response_url(@response.app, @response), params: { response: { match_value: 'test1' } }, xhr: true

    @response.reload
    assert_equal 'test1', @response.match_value
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Response.count', -1) do
      delete admin_app_response_url(@response.app, @response), xhr: true
    end

    assert_response :success
  end
end
