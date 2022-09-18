require 'test_helper'
class Wechat::Panel::DevelopersControllerTest < ActionDispatch::IntegrationTest

  setup do
    @developer = developers(:one)
  end

  test 'index ok' do
    get url_for(controller: 'wechat/panel/developers')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'wechat/panel/developers')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('Developer.count') do
      post(
        url_for(controller: 'wechat/panel/developers', action: 'create'),
        params: { developer: { encoding_aes_key: @wechat_panel_developer.encoding_aes_key, name: @wechat_panel_developer.name, token: @wechat_panel_developer.token } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'wechat/panel/developers', action: 'show', id: @developer.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'wechat/panel/developers', action: 'edit', id: @developer.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'wechat/panel/developers', action: 'update', id: @developer.id),
      params: { developer: { encoding_aes_key: @wechat_panel_developer.encoding_aes_key, name: @wechat_panel_developer.name, token: @wechat_panel_developer.token } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Developer.count', -1) do
      delete url_for(controller: 'wechat/panel/developers', action: 'destroy', id: @developer.id), as: :turbo_stream
    end

    assert_response :success
  end

end
