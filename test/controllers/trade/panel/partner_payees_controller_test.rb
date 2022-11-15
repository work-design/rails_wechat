require 'test_helper'
class Trade::Panel::PartnerPayeesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @partner_payee = partner_payees(:one)
  end

  test 'index ok' do
    get url_for(controller: 'trade/panel/partner_payees')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'trade/panel/partner_payees')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('PartnerPayee.count') do
      post(
        url_for(controller: 'trade/panel/partner_payees', action: 'create'),
        params: { partner_payee: { mch_id: @trade_panel_partner_payee.mch_id, name: @trade_panel_partner_payee.name } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'trade/panel/partner_payees', action: 'show', id: @partner_payee.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'trade/panel/partner_payees', action: 'edit', id: @partner_payee.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'trade/panel/partner_payees', action: 'update', id: @partner_payee.id),
      params: { partner_payee: { mch_id: @trade_panel_partner_payee.mch_id, name: @trade_panel_partner_payee.name } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('PartnerPayee.count', -1) do
      delete url_for(controller: 'trade/panel/partner_payees', action: 'destroy', id: @partner_payee.id), as: :turbo_stream
    end

    assert_response :success
  end

end
