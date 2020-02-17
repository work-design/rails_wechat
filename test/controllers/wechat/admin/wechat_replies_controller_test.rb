require 'test_helper'
class Wechat::Admin::WechatRepliesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @wechat_reply = create wechat_admin_wechat_replies
  end

  test 'index ok' do
    get admin_wechat_replies_url
    assert_response :success
  end

  test 'new ok' do
    get new_admin_wechat_reply_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('WechatReply.count') do
      post admin_wechat_replies_url, params: { wechat_reply: { } }
    end

    assert_response :success
  end

  test 'show ok' do
    get admin_wechat_reply_url(@wechat_reply)
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_wechat_reply_url(@wechat_reply)
    assert_response :success
  end

  test 'update ok' do
    patch admin_wechat_reply_url(@wechat_reply), params: { wechat_reply: { } }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('WechatReply.count', -1) do
      delete admin_wechat_reply_url(@wechat_reply)
    end

    assert_response :success
  end

end
