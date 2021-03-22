require 'test_helper'
class Wechat::Admin::MenusControllerTest < ActionDispatch::IntegrationTest

  setup do
    @menu = create :menu
  end

  test 'index ok' do
    get admin_menus_url(wechat_app_id: @menu.app)
    assert_response :success
  end

  test 'new ok' do
    get new_admin_menu_url(wechat_app_id: @menu.app), xhr: true
    assert_response :success
  end

  test 'create ok' do
    assert_difference('Menu.count') do
      post admin_menus_url, params: { menu: { name: 'test', value: '1' } }, xhr: true
    end

    assert_response :success
  end

  test 'show ok' do
    get admin_menu_url(@menu), xhr: true
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_menu_url(@menu), xhr: true
    assert_response :success
  end

  test 'update ok' do
    patch admin_menu_url(@menu), params: { menu: { name: 'test', value: '2' } }, xhr: true
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Menu.count', -1) do
      delete admin_wechat_menu_url(@wechat_menu), xhr: true
    end

    assert_response :success
  end

end
