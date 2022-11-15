require "application_system_test_case"

class PartnerPayeesTest < ApplicationSystemTestCase
  setup do
    @trade_panel_partner_payee = trade_panel_partner_payees(:one)
  end

  test "visiting the index" do
    visit trade_panel_partner_payees_url
    assert_selector "h1", text: "Partner payees"
  end

  test "should create partner payee" do
    visit trade_panel_partner_payees_url
    click_on "New partner payee"

    fill_in "Mch", with: @trade_panel_partner_payee.mch_id
    fill_in "Name", with: @trade_panel_partner_payee.name
    click_on "Create Partner payee"

    assert_text "Partner payee was successfully created"
    click_on "Back"
  end

  test "should update Partner payee" do
    visit trade_panel_partner_payee_url(@trade_panel_partner_payee)
    click_on "Edit this partner payee", match: :first

    fill_in "Mch", with: @trade_panel_partner_payee.mch_id
    fill_in "Name", with: @trade_panel_partner_payee.name
    click_on "Update Partner payee"

    assert_text "Partner payee was successfully updated"
    click_on "Back"
  end

  test "should destroy Partner payee" do
    visit trade_panel_partner_payee_url(@trade_panel_partner_payee)
    click_on "Destroy this partner payee", match: :first

    assert_text "Partner payee was successfully destroyed"
  end
end
