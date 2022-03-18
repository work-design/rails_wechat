require "application_system_test_case"

class ExternalsTest < ApplicationSystemTestCase
  setup do
    @wechat_panel_external = wechat_panel_externals(:one)
  end

  test "visiting the index" do
    visit wechat_panel_externals_url
    assert_selector "h1", text: "Externals"
  end

  test "should create external" do
    visit wechat_panel_externals_url
    click_on "New external"

    fill_in "Add way", with: @wechat_panel_external.add_way
    fill_in "Corp", with: @wechat_panel_external.corp_id
    fill_in "Gender", with: @wechat_panel_external.gender
    fill_in "Name", with: @wechat_panel_external.name
    fill_in "Remark", with: @wechat_panel_external.remark
    fill_in "State", with: @wechat_panel_external.state
    fill_in "Userid", with: @wechat_panel_external.userid
    click_on "Create External"

    assert_text "External was successfully created"
    click_on "Back"
  end

  test "should update External" do
    visit wechat_panel_external_url(@wechat_panel_external)
    click_on "Edit this external", match: :first

    fill_in "Add way", with: @wechat_panel_external.add_way
    fill_in "Corp", with: @wechat_panel_external.corp_id
    fill_in "Gender", with: @wechat_panel_external.gender
    fill_in "Name", with: @wechat_panel_external.name
    fill_in "Remark", with: @wechat_panel_external.remark
    fill_in "State", with: @wechat_panel_external.state
    fill_in "Userid", with: @wechat_panel_external.userid
    click_on "Update External"

    assert_text "External was successfully updated"
    click_on "Back"
  end

  test "should destroy External" do
    visit wechat_panel_external_url(@wechat_panel_external)
    click_on "Destroy this external", match: :first

    assert_text "External was successfully destroyed"
  end
end
