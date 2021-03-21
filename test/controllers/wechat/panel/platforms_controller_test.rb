require 'test_helper'
class Wechat::Panel::PlatformsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @platform = create :platform
  end

  test 'index ok' do
    get panel_platforms_url
    assert_response :success
  end

  test 'new ok' do
    get new_panel_platform_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('Platform.count') do
      post panel_platforms_url, params: { }
    end

    assert_response :success
  end

  test 'show ok' do
    get panel_platform_url(@platform)
    assert_response :success
  end

  test 'edit ok' do
    get edit_panel_wechat_platform_url(@wechat_panel_wechat_platform)
    assert_response :success
  end

  test 'update ok' do
    patch panel_wechat_platform_url(@wechat_panel_wechat_platform), params: { }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Platform.count', -1) do
      delete panel_wechat_platform_url(@wechat_panel_wechat_platform)
    end

    assert_response :success
  end

end
