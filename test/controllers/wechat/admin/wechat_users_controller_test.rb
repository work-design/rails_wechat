require 'test_helper'

class Wechat::Admin::WechatUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @wechat_admin_wechat_user = create wechat_admin_wechat_users
  end

  test 'index ok' do
    get admin_wechat_users_url
    assert_response :success
  end

  test 'new ok' do
    get new_admin_wechat_user_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('WechatUser.count') do
      post admin_wechat_users_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_redirected_to wechat_admin_wechat_user_url(WechatUser.last)
  end

  test 'show ok' do
    get admin_wechat_user_url(@wechat_admin_wechat_user)
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_wechat_user_url(@wechat_admin_wechat_user)
    assert_response :success
  end

  test 'update ok' do
    patch admin_wechat_user_url(@wechat_admin_wechat_user), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_redirected_to wechat_admin_wechat_user_url(@#{singular_table_name})
  end

  test 'destroy ok' do
    assert_difference('WechatUser.count', -1) do
      delete admin_wechat_user_url(@wechat_admin_wechat_user)
    end

    assert_redirected_to admin_wechat_users_url
  end
end
