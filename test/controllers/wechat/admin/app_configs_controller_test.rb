require 'test_helper'
class Wechat::Admin::AppConfigsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @app_config = app_configs(:one)
  end

  test 'index ok' do
    get url_for(controller: 'wechat/admin/app_configs')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'wechat/admin/app_configs')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('AppConfig.count') do
      post(
        url_for(controller: 'wechat/admin/app_configs', action: 'create'),
        params: { app_config: { key: @wechat_admin_app_config.key, value: @wechat_admin_app_config.value } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'wechat/admin/app_configs', action: 'show', id: @app_config.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'wechat/admin/app_configs', action: 'edit', id: @app_config.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'wechat/admin/app_configs', action: 'update', id: @app_config.id),
      params: { app_config: { key: @wechat_admin_app_config.key, value: @wechat_admin_app_config.value } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('AppConfig.count', -1) do
      delete url_for(controller: 'wechat/admin/app_configs', action: 'destroy', id: @app_config.id), as: :turbo_stream
    end

    assert_response :success
  end

end
