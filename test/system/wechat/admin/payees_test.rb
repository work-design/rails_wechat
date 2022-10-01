require "application_system_test_case"

class PayeesTest < ApplicationSystemTestCase
  setup do
    @wechat_admin_payee = wechat_admin_payees(:one)
  end

  test "visiting the index" do
    visit wechat_admin_payees_url
    assert_selector "h1", text: "Payees"
  end

  test "should create payee" do
    visit wechat_admin_payees_url
    click_on "New payee"

    fill_in "Apiclient cert", with: @wechat_admin_payee.apiclient_cert
    fill_in "Apiclient key", with: @wechat_admin_payee.apiclient_key
    fill_in "Key", with: @wechat_admin_payee.key
    fill_in "Key v3", with: @wechat_admin_payee.key_v3
    fill_in "Mch", with: @wechat_admin_payee.mch_id
    fill_in "Serial no", with: @wechat_admin_payee.serial_no
    click_on "Create Payee"

    assert_text "Payee was successfully created"
    click_on "Back"
  end

  test "should update Payee" do
    visit wechat_admin_payee_url(@wechat_admin_payee)
    click_on "Edit this payee", match: :first

    fill_in "Apiclient cert", with: @wechat_admin_payee.apiclient_cert
    fill_in "Apiclient key", with: @wechat_admin_payee.apiclient_key
    fill_in "Key", with: @wechat_admin_payee.key
    fill_in "Key v3", with: @wechat_admin_payee.key_v3
    fill_in "Mch", with: @wechat_admin_payee.mch_id
    fill_in "Serial no", with: @wechat_admin_payee.serial_no
    click_on "Update Payee"

    assert_text "Payee was successfully updated"
    click_on "Back"
  end

  test "should destroy Payee" do
    visit wechat_admin_payee_url(@wechat_admin_payee)
    click_on "Destroy this payee", match: :first

    assert_text "Payee was successfully destroyed"
  end
end
