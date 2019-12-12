require "application_system_test_case"

class WechatSubscribedsTest < ApplicationSystemTestCase
  setup do
    @wechat_my_wechat_subscribed = wechat_my_wechat_subscribeds(:one)
  end

  test "visiting the index" do
    visit wechat_my_wechat_subscribeds_url
    assert_selector "h1", text: "Wechat Subscribeds"
  end

  test "creating a Wechat subscribed" do
    visit wechat_my_wechat_subscribeds_url
    click_on "New Wechat Subscribed"

    fill_in "Sending at", with: @wechat_my_wechat_subscribed.sending_at
    fill_in "Status", with: @wechat_my_wechat_subscribed.status
    fill_in "Wechat template", with: @wechat_my_wechat_subscribed.wechat_template
    click_on "Create Wechat subscribed"

    assert_text "Wechat subscribed was successfully created"
    click_on "Back"
  end

  test "updating a Wechat subscribed" do
    visit wechat_my_wechat_subscribeds_url
    click_on "Edit", match: :first

    fill_in "Sending at", with: @wechat_my_wechat_subscribed.sending_at
    fill_in "Status", with: @wechat_my_wechat_subscribed.status
    fill_in "Wechat template", with: @wechat_my_wechat_subscribed.wechat_template
    click_on "Update Wechat subscribed"

    assert_text "Wechat subscribed was successfully updated"
    click_on "Back"
  end

  test "destroying a Wechat subscribed" do
    visit wechat_my_wechat_subscribeds_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Wechat subscribed was successfully destroyed"
  end
end
