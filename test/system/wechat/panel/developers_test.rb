require "application_system_test_case"

class DevelopersTest < ApplicationSystemTestCase
  setup do
    @wechat_panel_developer = wechat_panel_developers(:one)
  end

  test "visiting the index" do
    visit wechat_panel_developers_url
    assert_selector "h1", text: "Developers"
  end

  test "should create developer" do
    visit wechat_panel_developers_url
    click_on "New developer"

    fill_in "Encoding aes key", with: @wechat_panel_developer.encoding_aes_key
    fill_in "Name", with: @wechat_panel_developer.name
    fill_in "Token", with: @wechat_panel_developer.token
    click_on "Create Developer"

    assert_text "Developer was successfully created"
    click_on "Back"
  end

  test "should update Developer" do
    visit wechat_panel_developer_url(@wechat_panel_developer)
    click_on "Edit this developer", match: :first

    fill_in "Encoding aes key", with: @wechat_panel_developer.encoding_aes_key
    fill_in "Name", with: @wechat_panel_developer.name
    fill_in "Token", with: @wechat_panel_developer.token
    click_on "Update Developer"

    assert_text "Developer was successfully updated"
    click_on "Back"
  end

  test "should destroy Developer" do
    visit wechat_panel_developer_url(@wechat_panel_developer)
    click_on "Destroy this developer", match: :first

    assert_text "Developer was successfully destroyed"
  end
end
