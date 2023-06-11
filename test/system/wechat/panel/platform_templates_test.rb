require "application_system_test_case"

class PlatformTemplatesTest < ApplicationSystemTestCase
  setup do
    @wechat_panel_platform_template = wechat_panel_platform_templates(:one)
  end

  test "visiting the index" do
    visit wechat_panel_platform_templates_url
    assert_selector "h1", text: "Platform templates"
  end

  test "should create platform template" do
    visit wechat_panel_platform_templates_url
    click_on "New platform template"

    fill_in "Audit status", with: @wechat_panel_platform_template.audit_status
    fill_in "Template", with: @wechat_panel_platform_template.template_id
    fill_in "User version", with: @wechat_panel_platform_template.user_version
    click_on "Create Platform template"

    assert_text "Platform template was successfully created"
    click_on "Back"
  end

  test "should update Platform template" do
    visit wechat_panel_platform_template_url(@wechat_panel_platform_template)
    click_on "Edit this platform template", match: :first

    fill_in "Audit status", with: @wechat_panel_platform_template.audit_status
    fill_in "Template", with: @wechat_panel_platform_template.template_id
    fill_in "User version", with: @wechat_panel_platform_template.user_version
    click_on "Update Platform template"

    assert_text "Platform template was successfully updated"
    click_on "Back"
  end

  test "should destroy Platform template" do
    visit wechat_panel_platform_template_url(@wechat_panel_platform_template)
    click_on "Destroy this platform template", match: :first

    assert_text "Platform template was successfully destroyed"
  end
end
