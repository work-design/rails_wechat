require "application_system_test_case"

class WechatTemplatesTest < ApplicationSystemTestCase
  setup do
    @wechat_admin_wechat_template = wechat_admin_wechat_templates(:one)
  end

  test "visiting the index" do
    visit wechat_admin_wechat_templates_url
    assert_selector "h1", text: "Wechat Templates"
  end

  test "creating a Wechat template" do
    visit wechat_admin_wechat_templates_url
    click_on "New Wechat Template"

    fill_in "Content", with: @wechat_admin_wechat_template.content
    fill_in "Example", with: @wechat_admin_wechat_template.example
    fill_in "Template", with: @wechat_admin_wechat_template.template_id
    fill_in "Template type", with: @wechat_admin_wechat_template.template_type
    fill_in "Title", with: @wechat_admin_wechat_template.title
    click_on "Create Wechat template"

    assert_text "Wechat template was successfully created"
    click_on "Back"
  end

  test "updating a Wechat template" do
    visit wechat_admin_wechat_templates_url
    click_on "Edit", match: :first

    fill_in "Content", with: @wechat_admin_wechat_template.content
    fill_in "Example", with: @wechat_admin_wechat_template.example
    fill_in "Template", with: @wechat_admin_wechat_template.template_id
    fill_in "Template type", with: @wechat_admin_wechat_template.template_type
    fill_in "Title", with: @wechat_admin_wechat_template.title
    click_on "Update Wechat template"

    assert_text "Wechat template was successfully updated"
    click_on "Back"
  end

  test "destroying a Wechat template" do
    visit wechat_admin_wechat_templates_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Wechat template was successfully destroyed"
  end
end
