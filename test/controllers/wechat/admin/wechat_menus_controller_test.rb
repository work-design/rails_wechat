require 'test_helper'
class Wechat::Admin::MenusControllerTest < ActionDispatch::IntegrationTest

  setup do
    @wechat_menu = create :wechat_menu
  end

  test 'index ok' do
    get admin_wechat_menus_url(wechat_app_id: @wechat_menu.app)
    assert_response :success
  end

  test 'new ok' do
    get new_admin_wechat_menu_url(wechat_app_id: @wechat_menu.app), xhr: true
    assert_response :success
  end

  test 'create ok' do
    assert_difference('Menu.count') do
      post admin_wechat_menus_url, params: { wechat_menu: { name: 'test', value: '1' } }, xhr: true
    end

    assert_response :success
  end

  test 'show ok' do
    get admin_wechat_menu_url(@wechat_menu), xhr: true
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_wechat_menu_url(@wechat_menu), xhr: true
    assert_response :success
  end

  test 'update ok' do
    patch admin_wechat_menu_url(@wechat_menu), params: { wechat_menu: { name: 'test', value: '2' } }, xhr: true
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Menu.count', -1) do
      delete admin_wechat_menu_url(@wechat_menu), xhr: true
    end

    assert_response :success
  end

end
