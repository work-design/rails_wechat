require 'test_helper'
class Wechat::PlatformsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @platform = create :platforms
  end

  test 'index ok' do
    get platforms_url
    assert_response :success
  end

  test 'new ok' do
    get new_platform_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('Platform.count') do
      post platforms_url, params: { }
    end

    assert_response :success
  end

  test 'show ok' do
    get platform_url(@platform)
    assert_response :success
  end

  test 'edit ok' do
    get edit_platform_url(@platform)
    assert_response :success
  end

  test 'update ok' do
    patch platform_url(@platform), params: { }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Platform.count', -1) do
      delete platform_url(@platform)
    end

    assert_response :success
  end

end
