require 'test_helper'
class Wechat::Panel::CorpsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @corp = corps(:one)
  end

  test 'index ok' do
    get url_for(controller: 'wechat/panel/corps')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'wechat/panel/corps')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('Corp.count') do
      post(
        url_for(controller: 'wechat/panel/corps', action: 'create'),
        params: { corp: { corp_id: @wechat_panel_corp.corp_id, crop_type: @wechat_panel_corp.crop_type, full_name: @wechat_panel_corp.full_name, industry: @wechat_panel_corp.industry, name: @wechat_panel_corp.name, square_logo_url: @wechat_panel_corp.square_logo_url, subject_type: @wechat_panel_corp.subject_type } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'wechat/panel/corps', action: 'show', id: @corp.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'wechat/panel/corps', action: 'edit', id: @corp.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'wechat/panel/corps', action: 'update', id: @corp.id),
      params: { corp: { corp_id: @wechat_panel_corp.corp_id, crop_type: @wechat_panel_corp.crop_type, full_name: @wechat_panel_corp.full_name, industry: @wechat_panel_corp.industry, name: @wechat_panel_corp.name, square_logo_url: @wechat_panel_corp.square_logo_url, subject_type: @wechat_panel_corp.subject_type } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Corp.count', -1) do
      delete url_for(controller: 'wechat/panel/corps', action: 'destroy', id: @corp.id), as: :turbo_stream
    end

    assert_response :success
  end

end
