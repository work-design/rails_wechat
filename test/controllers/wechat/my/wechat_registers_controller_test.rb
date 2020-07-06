require 'test_helper'
class Wechat::My::WechatRegistersControllerTest < ActionDispatch::IntegrationTest

  setup do
    @wechat_my_wechat_register = create wechat_my_wechat_registers
  end

  test 'index ok' do
    get my_wechat_registers_url
    assert_response :success
  end

  test 'new ok' do
    get new_my_wechat_register_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('WechatRegister.count') do
      post my_wechat_registers_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_response :success
  end

  test 'show ok' do
    get my_wechat_register_url(@wechat_my_wechat_register)
    assert_response :success
  end

  test 'edit ok' do
    get edit_my_wechat_register_url(@wechat_my_wechat_register)
    assert_response :success
  end

  test 'update ok' do
    patch my_wechat_register_url(@wechat_my_wechat_register), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('WechatRegister.count', -1) do
      delete my_wechat_register_url(@wechat_my_wechat_register)
    end

    assert_response :success
  end

end
