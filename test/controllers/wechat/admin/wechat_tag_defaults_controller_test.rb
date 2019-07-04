require 'test_helper'

class Wechat::Admin::WechatTagDefaultsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @wechat_admin_wechat_tag_default = create wechat_admin_wechat_tag_defaults
  end

  test 'index ok' do
    get admin_wechat_tag_defaults_url
    assert_response :success
  end

  test 'new ok' do
    get new_admin_wechat_tag_default_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('WechatTagDefault.count') do
      post admin_wechat_tag_defaults_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_redirected_to wechat_admin_wechat_tag_default_url(WechatTagDefault.last)
  end

  test 'show ok' do
    get admin_wechat_tag_default_url(@wechat_admin_wechat_tag_default)
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_wechat_tag_default_url(@wechat_admin_wechat_tag_default)
    assert_response :success
  end

  test 'update ok' do
    patch admin_wechat_tag_default_url(@wechat_admin_wechat_tag_default), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_redirected_to wechat_admin_wechat_tag_default_url(@#{singular_table_name})
  end

  test 'destroy ok' do
    assert_difference('WechatTagDefault.count', -1) do
      delete admin_wechat_tag_default_url(@wechat_admin_wechat_tag_default)
    end

    assert_redirected_to admin_wechat_tag_defaults_url
  end
end
