require 'test_helper'
class Wechat::Admin::ReceiversControllerTest < ActionDispatch::IntegrationTest

  setup do
    @receiver = receivers(:one)
  end

  test 'index ok' do
    get url_for(controller: 'wechat/admin/receivers')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'wechat/admin/receivers')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('Receiver.count') do
      post(
        url_for(controller: 'wechat/admin/receivers', action: 'create'),
        params: { receiver: { account: @wechat_admin_receiver.account, custom_relation: @wechat_admin_receiver.custom_relation, name: @wechat_admin_receiver.name, receiver_type: @wechat_admin_receiver.receiver_type, relation_type: @wechat_admin_receiver.relation_type } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'wechat/admin/receivers', action: 'show', id: @receiver.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'wechat/admin/receivers', action: 'edit', id: @receiver.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'wechat/admin/receivers', action: 'update', id: @receiver.id),
      params: { receiver: { account: @wechat_admin_receiver.account, custom_relation: @wechat_admin_receiver.custom_relation, name: @wechat_admin_receiver.name, receiver_type: @wechat_admin_receiver.receiver_type, relation_type: @wechat_admin_receiver.relation_type } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Receiver.count', -1) do
      delete url_for(controller: 'wechat/admin/receivers', action: 'destroy', id: @receiver.id), as: :turbo_stream
    end

    assert_response :success
  end

end
