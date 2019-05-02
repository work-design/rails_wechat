require 'test_helper'

class Wechat::Admin::WechatMenusControllerTest < ActionDispatch::IntegrationTest
  setup do
    @wechat_admin_wechat_menu = create wechat_admin_wechat_menus
  end

  test 'index ok' do
    get admin_wechat_menus_url
    assert_response :success
  end

  test 'new ok' do
    get new_admin_wechat_menu_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('WechatMenu.count') do
      post admin_wechat_menus_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_redirected_to wechat_admin_wechat_menu_url(WechatMenu.last)
  end

  test 'show ok' do
    get admin_wechat_menu_url(@wechat_admin_wechat_menu)
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_wechat_menu_url(@wechat_admin_wechat_menu)
    assert_response :success
  end

  test 'update ok' do
    patch admin_wechat_menu_url(@wechat_admin_wechat_menu), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_redirected_to wechat_admin_wechat_menu_url(@#{singular_table_name})
  end

  test 'destroy ok' do
    assert_difference('WechatMenu.count', -1) do
      delete admin_wechat_menu_url(@wechat_admin_wechat_menu)
    end

    assert_redirected_to admin_wechat_menus_url
  end
end
