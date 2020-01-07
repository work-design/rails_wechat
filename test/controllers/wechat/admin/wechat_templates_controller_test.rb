require 'test_helper'
class Wechat::Admin::WechatTemplatesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @wechat_template = create :wechat_template
  end

  test 'index ok' do
    get admin_wechat_templates_url
    assert_response :success
  end

  test 'new ok' do
    get new_admin_wechat_template_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('WechatTemplate.count') do
      post admin_wechat_templates_url, params: {  }
    end

    assert_response :success
  end

  test 'show ok' do
    get admin_wechat_template_url(@wechat_template)
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_wechat_template_url(@wechat_template)
    assert_response :success
  end

  test 'update ok' do
    patch admin_wechat_template_url(@wechat_template), params: {  }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('WechatTemplate.count', -1) do
      delete admin_wechat_template_url(@wechat_template)
    end

    assert_response :success
  end

end
