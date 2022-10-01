require 'test_helper'
class Wechat::Admin::PayeesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @payee = payees(:one)
  end

  test 'index ok' do
    get url_for(controller: 'wechat/admin/payees')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'wechat/admin/payees')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('Payee.count') do
      post(
        url_for(controller: 'wechat/admin/payees', action: 'create'),
        params: { payee: { apiclient_cert: @wechat_admin_payee.apiclient_cert, apiclient_key: @wechat_admin_payee.apiclient_key, key: @wechat_admin_payee.key, key_v3: @wechat_admin_payee.key_v3, mch_id: @wechat_admin_payee.mch_id, serial_no: @wechat_admin_payee.serial_no } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'wechat/admin/payees', action: 'show', id: @payee.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'wechat/admin/payees', action: 'edit', id: @payee.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'wechat/admin/payees', action: 'update', id: @payee.id),
      params: { payee: { apiclient_cert: @wechat_admin_payee.apiclient_cert, apiclient_key: @wechat_admin_payee.apiclient_key, key: @wechat_admin_payee.key, key_v3: @wechat_admin_payee.key_v3, mch_id: @wechat_admin_payee.mch_id, serial_no: @wechat_admin_payee.serial_no } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Payee.count', -1) do
      delete url_for(controller: 'wechat/admin/payees', action: 'destroy', id: @payee.id), as: :turbo_stream
    end

    assert_response :success
  end

end
