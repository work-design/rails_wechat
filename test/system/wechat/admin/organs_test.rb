require "application_system_test_case"

class OrgansTest < ApplicationSystemTestCase
  setup do
    @wechat_admin_organ = wechat_admin_organs(:one)
  end

  test "visiting the index" do
    visit wechat_admin_organs_url
    assert_selector "h1", text: "Organs"
  end

  test "should create organ" do
    visit wechat_admin_organs_url
    click_on "New organ"

    fill_in "Corp", with: @wechat_admin_organ.corp_id
    fill_in "Name", with: @wechat_admin_organ.name
    click_on "Create Organ"

    assert_text "Organ was successfully created"
    click_on "Back"
  end

  test "should update Organ" do
    visit wechat_admin_organ_url(@wechat_admin_organ)
    click_on "Edit this organ", match: :first

    fill_in "Corp", with: @wechat_admin_organ.corp_id
    fill_in "Name", with: @wechat_admin_organ.name
    click_on "Update Organ"

    assert_text "Organ was successfully updated"
    click_on "Back"
  end

  test "should destroy Organ" do
    visit wechat_admin_organ_url(@wechat_admin_organ)
    click_on "Destroy this organ", match: :first

    assert_text "Organ was successfully destroyed"
  end
end
