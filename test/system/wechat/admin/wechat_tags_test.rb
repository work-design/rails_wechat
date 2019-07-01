require "application_system_test_case"

class WechatTagsTest < ApplicationSystemTestCase
  setup do
    @wechat_admin_wechat_tag = wechat_admin_wechat_tags(:one)
  end

  test "visiting the index" do
    visit wechat_admin_wechat_tags_url
    assert_selector "h1", text: "Wechat Tags"
  end

  test "creating a Wechat tag" do
    visit wechat_admin_wechat_tags_url
    click_on "New Wechat Tag"

    fill_in "Name", with: @wechat_admin_wechat_tag.name
    fill_in "Tag count", with: @wechat_admin_wechat_tag.tag_count
    fill_in "Tag", with: @wechat_admin_wechat_tag.tag_id
    fill_in "Tag name", with: @wechat_admin_wechat_tag.tag_name
    click_on "Create Wechat tag"

    assert_text "Wechat tag was successfully created"
    click_on "Back"
  end

  test "updating a Wechat tag" do
    visit wechat_admin_wechat_tags_url
    click_on "Edit", match: :first

    fill_in "Name", with: @wechat_admin_wechat_tag.name
    fill_in "Tag count", with: @wechat_admin_wechat_tag.tag_count
    fill_in "Tag", with: @wechat_admin_wechat_tag.tag_id
    fill_in "Tag name", with: @wechat_admin_wechat_tag.tag_name
    click_on "Update Wechat tag"

    assert_text "Wechat tag was successfully updated"
    click_on "Back"
  end

  test "destroying a Wechat tag" do
    visit wechat_admin_wechat_tags_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Wechat tag was successfully destroyed"
  end
end
