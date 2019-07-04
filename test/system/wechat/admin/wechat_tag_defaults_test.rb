require "application_system_test_case"

class WechatTagDefaultsTest < ApplicationSystemTestCase
  setup do
    @wechat_admin_wechat_tag_default = wechat_admin_wechat_tag_defaults(:one)
  end

  test "visiting the index" do
    visit wechat_admin_wechat_tag_defaults_url
    assert_selector "h1", text: "Wechat Tag Defaults"
  end

  test "creating a Wechat tag default" do
    visit wechat_admin_wechat_tag_defaults_url
    click_on "New Wechat Tag Default"

    fill_in "Default type", with: @wechat_admin_wechat_tag_default.default_type
    fill_in "Name", with: @wechat_admin_wechat_tag_default.name
    click_on "Create Wechat tag default"

    assert_text "Wechat tag default was successfully created"
    click_on "Back"
  end

  test "updating a Wechat tag default" do
    visit wechat_admin_wechat_tag_defaults_url
    click_on "Edit", match: :first

    fill_in "Default type", with: @wechat_admin_wechat_tag_default.default_type
    fill_in "Name", with: @wechat_admin_wechat_tag_default.name
    click_on "Update Wechat tag default"

    assert_text "Wechat tag default was successfully updated"
    click_on "Back"
  end

  test "destroying a Wechat tag default" do
    visit wechat_admin_wechat_tag_defaults_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Wechat tag default was successfully destroyed"
  end
end
