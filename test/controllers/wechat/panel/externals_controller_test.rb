require 'test_helper'
class Wechat::Panel::ExternalsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @external = externals(:one)
  end

  test 'index ok' do
    get url_for(controller: 'wechat/panel/externals')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'wechat/panel/externals')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('External.count') do
      post(
        url_for(controller: 'wechat/panel/externals', action: 'create'),
        params: { external: { add_way: @wechat_panel_external.add_way, corp_id: @wechat_panel_external.corp_id, gender: @wechat_panel_external.gender, name: @wechat_panel_external.name, remark: @wechat_panel_external.remark, state: @wechat_panel_external.state, userid: @wechat_panel_external.userid } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'wechat/panel/externals', action: 'show', id: @external.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'wechat/panel/externals', action: 'edit', id: @external.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'wechat/panel/externals', action: 'update', id: @external.id),
      params: { external: { add_way: @wechat_panel_external.add_way, corp_id: @wechat_panel_external.corp_id, gender: @wechat_panel_external.gender, name: @wechat_panel_external.name, remark: @wechat_panel_external.remark, state: @wechat_panel_external.state, userid: @wechat_panel_external.userid } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('External.count', -1) do
      delete url_for(controller: 'wechat/panel/externals', action: 'destroy', id: @external.id), as: :turbo_stream
    end

    assert_response :success
  end

end
