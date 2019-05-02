require "application_system_test_case"

class WechatMenusTest < ApplicationSystemTestCase
  setup do
    @wechat_admin_wechat_menu = wechat_admin_wechat_menus(:one)
  end

  test "visiting the index" do
    visit wechat_admin_wechat_menus_url
    assert_selector "h1", text: "Wechat Menus"
  end

  test "creating a Wechat menu" do
    visit wechat_admin_wechat_menus_url
    click_on "New Wechat Menu"

    fill_in "Appid", with: @wechat_admin_wechat_menu.appid
    fill_in "Menu type", with: @wechat_admin_wechat_menu.menu_type
    fill_in "Name", with: @wechat_admin_wechat_menu.name
    fill_in "Pagepath", with: @wechat_admin_wechat_menu.pagepath
    fill_in "Value", with: @wechat_admin_wechat_menu.value
    click_on "Create Wechat menu"

    assert_text "Wechat menu was successfully created"
    click_on "Back"
  end

  test "updating a Wechat menu" do
    visit wechat_admin_wechat_menus_url
    click_on "Edit", match: :first

    fill_in "Appid", with: @wechat_admin_wechat_menu.appid
    fill_in "Menu type", with: @wechat_admin_wechat_menu.menu_type
    fill_in "Name", with: @wechat_admin_wechat_menu.name
    fill_in "Pagepath", with: @wechat_admin_wechat_menu.pagepath
    fill_in "Value", with: @wechat_admin_wechat_menu.value
    click_on "Update Wechat menu"

    assert_text "Wechat menu was successfully updated"
    click_on "Back"
  end

  test "destroying a Wechat menu" do
    visit wechat_admin_wechat_menus_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Wechat menu was successfully destroyed"
  end
end
