require 'test_helper'

class Wechat::Admin::WechatResponsesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @wechat_admin_wechat_response = create wechat_admin_wechat_responses
  end

  test 'index ok' do
    get admin_wechat_responses_url
    assert_response :success
  end

  test 'new ok' do
    get new_admin_wechat_response_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('WechatResponse.count') do
      post admin_wechat_responses_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_redirected_to wechat_admin_wechat_response_url(WechatResponse.last)
  end

  test 'show ok' do
    get admin_wechat_response_url(@wechat_admin_wechat_response)
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_wechat_response_url(@wechat_admin_wechat_response)
    assert_response :success
  end

  test 'update ok' do
    patch admin_wechat_response_url(@wechat_admin_wechat_response), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_redirected_to wechat_admin_wechat_response_url(@#{singular_table_name})
  end

  test 'destroy ok' do
    assert_difference('WechatResponse.count', -1) do
      delete admin_wechat_response_url(@wechat_admin_wechat_response)
    end

    assert_redirected_to admin_wechat_responses_url
  end
end
