require 'test_helper'
class Wechat::Me::ExternalsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @external = externals(:one)
  end

  test 'index ok' do
    get url_for(controller: 'wechat/me/externals')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'wechat/me/externals')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('External.count') do
      post(
        url_for(controller: 'wechat/me/externals', action: 'create'),
        params: { external: { gender: @wechat_me_external.gender, name: @wechat_me_external.name, state: @wechat_me_external.state } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'wechat/me/externals', action: 'show', id: @external.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'wechat/me/externals', action: 'edit', id: @external.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'wechat/me/externals', action: 'update', id: @external.id),
      params: { external: { gender: @wechat_me_external.gender, name: @wechat_me_external.name, state: @wechat_me_external.state } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('External.count', -1) do
      delete url_for(controller: 'wechat/me/externals', action: 'destroy', id: @external.id), as: :turbo_stream
    end

    assert_response :success
  end

end
