require "application_system_test_case"

class ExtractorsTest < ApplicationSystemTestCase
  setup do
    @wechat_admin_extractor = wechat_admin_extractors(:one)
  end

  test "visiting the index" do
    visit wechat_admin_extractors_url
    assert_selector "h1", text: "Extractors"
  end

  test "creating a Extractor" do
    visit wechat_admin_extractors_url
    click_on "New Extractor"

    fill_in "Item separator", with: @wechat_admin_extractor.item_separator
    fill_in "Name", with: @wechat_admin_extractor.name
    fill_in "Value separator", with: @wechat_admin_extractor.value_separator
    click_on "Create Extractor"

    assert_text "Extractor was successfully created"
    click_on "Back"
  end

  test "updating a Extractor" do
    visit wechat_admin_extractors_url
    click_on "Edit", match: :first

    fill_in "Item separator", with: @wechat_admin_extractor.item_separator
    fill_in "Name", with: @wechat_admin_extractor.name
    fill_in "Value separator", with: @wechat_admin_extractor.value_separator
    click_on "Update Extractor"

    assert_text "Extractor was successfully updated"
    click_on "Back"
  end

  test "destroying a Extractor" do
    visit wechat_admin_extractors_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Extractor was successfully destroyed"
  end
end
