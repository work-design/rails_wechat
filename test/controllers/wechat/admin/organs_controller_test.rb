require 'test_helper'
class Wechat::Admin::OrgansControllerTest < ActionDispatch::IntegrationTest

  setup do
    @organ = organs(:one)
  end

  test 'index ok' do
    get url_for(controller: 'wechat/admin/organs')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'wechat/admin/organs')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('Organ.count') do
      post(
        url_for(controller: 'wechat/admin/organs', action: 'create'),
        params: { organ: { corp_id: @wechat_admin_organ.corp_id, name: @wechat_admin_organ.name } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'wechat/admin/organs', action: 'show', id: @organ.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'wechat/admin/organs', action: 'edit', id: @organ.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'wechat/admin/organs', action: 'update', id: @organ.id),
      params: { organ: { corp_id: @wechat_admin_organ.corp_id, name: @wechat_admin_organ.name } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Organ.count', -1) do
      delete url_for(controller: 'wechat/admin/organs', action: 'destroy', id: @organ.id), as: :turbo_stream
    end

    assert_response :success
  end

end
