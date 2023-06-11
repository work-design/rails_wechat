require 'test_helper'
class Wechat::Panel::PlatformTemplatesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @platform_template = platform_templates(:one)
  end

  test 'index ok' do
    get url_for(controller: 'wechat/panel/platform_templates')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'wechat/panel/platform_templates')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('PlatformTemplate.count') do
      post(
        url_for(controller: 'wechat/panel/platform_templates', action: 'create'),
        params: { platform_template: { audit_status: @wechat_panel_platform_template.audit_status, template_id: @wechat_panel_platform_template.template_id, user_version: @wechat_panel_platform_template.user_version } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'wechat/panel/platform_templates', action: 'show', id: @platform_template.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'wechat/panel/platform_templates', action: 'edit', id: @platform_template.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'wechat/panel/platform_templates', action: 'update', id: @platform_template.id),
      params: { platform_template: { audit_status: @wechat_panel_platform_template.audit_status, template_id: @wechat_panel_platform_template.template_id, user_version: @wechat_panel_platform_template.user_version } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('PlatformTemplate.count', -1) do
      delete url_for(controller: 'wechat/panel/platform_templates', action: 'destroy', id: @platform_template.id), as: :turbo_stream
    end

    assert_response :success
  end

end
