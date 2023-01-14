require 'test_helper'
class Wechat::Panel::MenuRootsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @menu_root = menu_roots(:one)
  end

  test 'index ok' do
    get url_for(controller: 'wechat/panel/menu_roots')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'wechat/panel/menu_roots')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('MenuRoot.count') do
      post(
        url_for(controller: 'wechat/panel/menu_roots', action: 'create'),
        params: { menu_root: { name: @wechat_panel_menu_root.name, position: @wechat_panel_menu_root.position } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'wechat/panel/menu_roots', action: 'show', id: @menu_root.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'wechat/panel/menu_roots', action: 'edit', id: @menu_root.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'wechat/panel/menu_roots', action: 'update', id: @menu_root.id),
      params: { menu_root: { name: @wechat_panel_menu_root.name, position: @wechat_panel_menu_root.position } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('MenuRoot.count', -1) do
      delete url_for(controller: 'wechat/panel/menu_roots', action: 'destroy', id: @menu_root.id), as: :turbo_stream
    end

    assert_response :success
  end

end
