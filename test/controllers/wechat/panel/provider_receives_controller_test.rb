require 'test_helper'
class Wechat::Panel::ProviderReceivesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @provider_receive = provider_receives(:one)
  end

  test 'index ok' do
    get url_for(controller: 'wechat/panel/provider_receives')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'wechat/panel/provider_receives')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('ProviderReceive.count') do
      post(
        url_for(controller: 'wechat/panel/provider_receives', action: 'create'),
        params: { provider_receive: { agent_id: @wechat_panel_provider_receive.agent_id, content: @wechat_panel_provider_receive.content, corp_id: @wechat_panel_provider_receive.corp_id, event: @wechat_panel_provider_receive.event, event_key: @wechat_panel_provider_receive.event_key, message_hash: @wechat_panel_provider_receive.message_hash, user_id: @wechat_panel_provider_receive.user_id } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'wechat/panel/provider_receives', action: 'show', id: @provider_receive.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'wechat/panel/provider_receives', action: 'edit', id: @provider_receive.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'wechat/panel/provider_receives', action: 'update', id: @provider_receive.id),
      params: { provider_receive: { agent_id: @wechat_panel_provider_receive.agent_id, content: @wechat_panel_provider_receive.content, corp_id: @wechat_panel_provider_receive.corp_id, event: @wechat_panel_provider_receive.event, event_key: @wechat_panel_provider_receive.event_key, message_hash: @wechat_panel_provider_receive.message_hash, user_id: @wechat_panel_provider_receive.user_id } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('ProviderReceive.count', -1) do
      delete url_for(controller: 'wechat/panel/provider_receives', action: 'destroy', id: @provider_receive.id), as: :turbo_stream
    end

    assert_response :success
  end

end
