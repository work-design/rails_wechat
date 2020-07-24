require 'test_helper'
class Wechat::WechatPlatformsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @wechat_wechat_platform = create wechat_wechat_platforms
  end

  test 'index ok' do
    get wechat_wechat_platforms_url
    assert_response :success
  end

  test 'new ok' do
    get new_wechat_wechat_platform_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('WechatPlatform.count') do
      post wechat_wechat_platforms_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_response :success
  end

  test 'show ok' do
    get wechat_wechat_platform_url(@wechat_wechat_platform)
    assert_response :success
  end

  test 'edit ok' do
    get edit_wechat_wechat_platform_url(@wechat_wechat_platform)
    assert_response :success
  end

  test 'update ok' do
    patch wechat_wechat_platform_url(@wechat_wechat_platform), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('WechatPlatform.count', -1) do
      delete wechat_wechat_platform_url(@wechat_wechat_platform)
    end

    assert_response :success
  end

end
