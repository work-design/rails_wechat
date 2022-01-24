require 'test_helper'
class Wechat::Panel::ProviderTicketsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @provider_ticket = provider_tickets(:one)
  end

  test 'index ok' do
    get url_for(controller: 'wechat/panel/provider_tickets')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'wechat/panel/provider_tickets')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('ProviderTicket.count') do
      post(
        url_for(controller: 'wechat/panel/provider_tickets', action: 'create'),
        params: { provider_ticket: { info_type: @wechat_panel_provider_ticket.info_type, message_hash: @wechat_panel_provider_ticket.message_hash } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'wechat/panel/provider_tickets', action: 'show', id: @provider_ticket.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'wechat/panel/provider_tickets', action: 'edit', id: @provider_ticket.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'wechat/panel/provider_tickets', action: 'update', id: @provider_ticket.id),
      params: { provider_ticket: { info_type: @wechat_panel_provider_ticket.info_type, message_hash: @wechat_panel_provider_ticket.message_hash } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('ProviderTicket.count', -1) do
      delete url_for(controller: 'wechat/panel/provider_tickets', action: 'destroy', id: @provider_ticket.id), as: :turbo_stream
    end

    assert_response :success
  end

end
