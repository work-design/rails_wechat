require "application_system_test_case"

class AppConfigsTest < ApplicationSystemTestCase
  setup do
    @wechat_admin_app_config = wechat_admin_app_configs(:one)
  end

  test "visiting the index" do
    visit wechat_admin_app_configs_url
    assert_selector "h1", text: "App configs"
  end

  test "should create app config" do
    visit wechat_admin_app_configs_url
    click_on "New app config"

    fill_in "Key", with: @wechat_admin_app_config.key
    fill_in "Value", with: @wechat_admin_app_config.value
    click_on "Create App config"

    assert_text "App config was successfully created"
    click_on "Back"
  end

  test "should update App config" do
    visit wechat_admin_app_config_url(@wechat_admin_app_config)
    click_on "Edit this app config", match: :first

    fill_in "Key", with: @wechat_admin_app_config.key
    fill_in "Value", with: @wechat_admin_app_config.value
    click_on "Update App config"

    assert_text "App config was successfully updated"
    click_on "Back"
  end

  test "should destroy App config" do
    visit wechat_admin_app_config_url(@wechat_admin_app_config)
    click_on "Destroy this app config", match: :first

    assert_text "App config was successfully destroyed"
  end
end
