require 'test_helper'
class Wechat::Admin::WechatResponsesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @wechat_response = create :wechat_response
  end

  test 'index ok' do
    get admin_wechat_app_wechat_responses_url(@wechat_response.app)
    assert_response :success
  end

  test 'new ok' do
    get new_admin_wechat_app_wechat_response_url(@wechat_response.app), xhr: true
    assert_response :success
  end

  test 'create ok' do
    assert_difference('WechatResponse.count') do
      post admin_wechat_app_wechat_responses_url(@wechat_response.app), params: { wechat_response: { match_value: 'test' } }, xhr: true
    end

    assert_response :success
  end

  test 'show ok' do
    get admin_wechat_app_wechat_response_url(@wechat_response.app, @wechat_response), xhr: true
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_wechat_app_wechat_response_url(@wechat_response.app, @wechat_response), xhr: true
    assert_response :success
  end

  test 'update ok' do
    patch admin_wechat_app_wechat_response_url(@wechat_response.app, @wechat_response), params: { wechat_response: { match_value: 'test1' } }, xhr: true
    
    @wechat_response.reload
    assert_equal 'test1', @wechat_response.match_value
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('WechatResponse.count', -1) do
      delete admin_wechat_app_wechat_response_url(@wechat_response.app, @wechat_response), xhr: true
    end

    assert_response :success
  end
end
