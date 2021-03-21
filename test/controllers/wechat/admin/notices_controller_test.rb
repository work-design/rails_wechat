require 'test_helper'
class Wechat::Admin::WechatNoticesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @wechat_notice = create :wechat_notice
  end

  test 'index ok' do
    get admin_wechat_notices_url
    assert_response :success
  end

  test 'new ok' do
    get new_admin_wechat_notice_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('WechatNotice.count') do
      post admin_wechat_notices_url, params: {  }
    end

    assert_response :success
  end

  test 'show ok' do
    get admin_wechat_notice_url(@wechat_notice)
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_wechat_notice_url(@wechat_notice)
    assert_response :success
  end

  test 'update ok' do
    patch admin_wechat_notice_url(@wechat_notice), params: {  }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('WechatNotice.count', -1) do
      delete admin_wechat_notice_url(@wechat_notice)
    end

    assert_response :success
  end

end
