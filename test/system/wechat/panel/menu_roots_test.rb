require "application_system_test_case"

class MenuRootsTest < ApplicationSystemTestCase
  setup do
    @wechat_panel_menu_root = wechat_panel_menu_roots(:one)
  end

  test "visiting the index" do
    visit wechat_panel_menu_roots_url
    assert_selector "h1", text: "Menu roots"
  end

  test "should create menu root" do
    visit wechat_panel_menu_roots_url
    click_on "New menu root"

    fill_in "Name", with: @wechat_panel_menu_root.name
    fill_in "Position", with: @wechat_panel_menu_root.position
    click_on "Create Menu root"

    assert_text "Menu root was successfully created"
    click_on "Back"
  end

  test "should update Menu root" do
    visit wechat_panel_menu_root_url(@wechat_panel_menu_root)
    click_on "Edit this menu root", match: :first

    fill_in "Name", with: @wechat_panel_menu_root.name
    fill_in "Position", with: @wechat_panel_menu_root.position
    click_on "Update Menu root"

    assert_text "Menu root was successfully updated"
    click_on "Back"
  end

  test "should destroy Menu root" do
    visit wechat_panel_menu_root_url(@wechat_panel_menu_root)
    click_on "Destroy this menu root", match: :first

    assert_text "Menu root was successfully destroyed"
  end
end
