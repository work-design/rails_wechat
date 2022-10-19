require "application_system_test_case"

class ReceiversTest < ApplicationSystemTestCase
  setup do
    @wechat_admin_receiver = wechat_admin_receivers(:one)
  end

  test "visiting the index" do
    visit wechat_admin_receivers_url
    assert_selector "h1", text: "Receivers"
  end

  test "should create receiver" do
    visit wechat_admin_receivers_url
    click_on "New receiver"

    fill_in "Account", with: @wechat_admin_receiver.account
    fill_in "Custom relation", with: @wechat_admin_receiver.custom_relation
    fill_in "Name", with: @wechat_admin_receiver.name
    fill_in "Receiver type", with: @wechat_admin_receiver.receiver_type
    fill_in "Relation type", with: @wechat_admin_receiver.relation_type
    click_on "Create Receiver"

    assert_text "Receiver was successfully created"
    click_on "Back"
  end

  test "should update Receiver" do
    visit wechat_admin_receiver_url(@wechat_admin_receiver)
    click_on "Edit this receiver", match: :first

    fill_in "Account", with: @wechat_admin_receiver.account
    fill_in "Custom relation", with: @wechat_admin_receiver.custom_relation
    fill_in "Name", with: @wechat_admin_receiver.name
    fill_in "Receiver type", with: @wechat_admin_receiver.receiver_type
    fill_in "Relation type", with: @wechat_admin_receiver.relation_type
    click_on "Update Receiver"

    assert_text "Receiver was successfully updated"
    click_on "Back"
  end

  test "should destroy Receiver" do
    visit wechat_admin_receiver_url(@wechat_admin_receiver)
    click_on "Destroy this receiver", match: :first

    assert_text "Receiver was successfully destroyed"
  end
end
