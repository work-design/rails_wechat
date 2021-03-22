require 'test_helper'
class Wechat::Admin::WechatUsersControllerTest < ActionDispatch::IntegrationTest

  setup do
    @app = create :app
    @wechat_user = create :wechat_user, app_id: @app.appid
  end

  test 'index ok' do
    get admin_app_wechat_users_url(@app)
    assert_response :success
  end

  test 'show ok' do
    get admin_app_wechat_user_url(@app, @wechat_user), xhr: true
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_app_wechat_user_url(@app, @wechat_user), xhr: true
    assert_response :success
  end

  test 'update ok' do
    patch admin_app_wechat_user_url(@app, @wechat_user), params: { }, xhr: true
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('WechatUser.count', -1) do
      delete admin_app_wechat_user_url(@app, @wechat_user), xhr: true
    end

    assert_response :success
  end

end
