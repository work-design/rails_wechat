require 'test_helper'
class Wechat::Admin::WechatRepliesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @reply = create wechat_admin_wechat_replies
  end

  test 'index ok' do
    get admin_wechat_replies_url
    assert_response :success
  end

  test 'new ok' do
    get new_admin_reply_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('Reply.count') do
      post admin_wechat_replies_url, params: { reply: { } }
    end

    assert_response :success
  end

  test 'show ok' do
    get admin_reply_url(@reply)
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_reply_url(@reply)
    assert_response :success
  end

  test 'update ok' do
    patch admin_reply_url(@reply), params: { reply: { } }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Reply.count', -1) do
      delete admin_reply_url(@reply)
    end

    assert_response :success
  end

end
