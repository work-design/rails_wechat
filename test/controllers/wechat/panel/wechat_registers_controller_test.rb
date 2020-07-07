require 'test_helper'
class Wechat::Panel::WechatRegistersControllerTest < ActionDispatch::IntegrationTest

  setup do
    @wechat_panel_wechat_register = create wechat_panel_wechat_registers
  end

  test 'index ok' do
    get panel_wechat_registers_url
    assert_response :success
  end

  test 'new ok' do
    get new_panel_wechat_register_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('WechatRegister.count') do
      post panel_wechat_registers_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_response :success
  end

  test 'show ok' do
    get panel_wechat_register_url(@wechat_panel_wechat_register)
    assert_response :success
  end

  test 'edit ok' do
    get edit_panel_wechat_register_url(@wechat_panel_wechat_register)
    assert_response :success
  end

  test 'update ok' do
    patch panel_wechat_register_url(@wechat_panel_wechat_register), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('WechatRegister.count', -1) do
      delete panel_wechat_register_url(@wechat_panel_wechat_register)
    end

    assert_response :success
  end

end
