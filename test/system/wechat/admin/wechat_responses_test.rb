require "application_system_test_case"

class WechatResponsesTest < ApplicationSystemTestCase
  setup do
    @wechat_admin_wechat_response = wechat_admin_wechat_responses(:one)
  end

  test "visiting the index" do
    visit wechat_admin_wechat_responses_url
    assert_selector "h1", text: "Wechat Responses"
  end

  test "creating a Wechat response" do
    visit wechat_admin_wechat_responses_url
    click_on "New Wechat Response"

    fill_in "Regexp", with: @wechat_admin_wechat_response.regexp
    fill_in "Response", with: @wechat_admin_wechat_response.response
    click_on "Create Wechat response"

    assert_text "Wechat response was successfully created"
    click_on "Back"
  end

  test "updating a Wechat response" do
    visit wechat_admin_wechat_responses_url
    click_on "Edit", match: :first

    fill_in "Regexp", with: @wechat_admin_wechat_response.regexp
    fill_in "Response", with: @wechat_admin_wechat_response.response
    click_on "Update Wechat response"

    assert_text "Wechat response was successfully updated"
    click_on "Back"
  end

  test "destroying a Wechat response" do
    visit wechat_admin_wechat_responses_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Wechat response was successfully destroyed"
  end
end
