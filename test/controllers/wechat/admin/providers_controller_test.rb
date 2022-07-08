require 'test_helper'
class Admin::Panel::ProvidersControllerTest < ActionDispatch::IntegrationTest

  setup do
    @provider = providers(:one)
  end

  test 'index ok' do
    get url_for(controller: 'admin/panel/providers')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'admin/panel/providers')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('Provider.count') do
      post(
        url_for(controller: 'admin/panel/providers', action: 'create'),
        params: { provider: { corp_id: @admin_panel_provider.corp_id, encoding_aes_key: @admin_panel_provider.encoding_aes_key, name: @admin_panel_provider.name, provider_secret: @admin_panel_provider.provider_secret, secret: @admin_panel_provider.secret, suite_id: @admin_panel_provider.suite_id, token: @admin_panel_provider.token } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'admin/panel/providers', action: 'show', id: @provider.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'admin/panel/providers', action: 'edit', id: @provider.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'admin/panel/providers', action: 'update', id: @provider.id),
      params: { provider: { corp_id: @admin_panel_provider.corp_id, encoding_aes_key: @admin_panel_provider.encoding_aes_key, name: @admin_panel_provider.name, provider_secret: @admin_panel_provider.provider_secret, secret: @admin_panel_provider.secret, suite_id: @admin_panel_provider.suite_id, token: @admin_panel_provider.token } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Provider.count', -1) do
      delete url_for(controller: 'admin/panel/providers', action: 'destroy', id: @provider.id), as: :turbo_stream
    end

    assert_response :success
  end

end
