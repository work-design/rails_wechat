require 'test_helper'
class Wechat::My::MediaControllerTest < ActionDispatch::IntegrationTest

  setup do
    @wechat_my_medium = create wechat_my_media
  end

  test 'index ok' do
    get my_media_url
    assert_response :success
  end

  test 'new ok' do
    get new_my_medium_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('Medium.count') do
      post my_media_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_response :success
  end

  test 'show ok' do
    get my_medium_url(@wechat_my_medium)
    assert_response :success
  end

  test 'edit ok' do
    get edit_my_medium_url(@wechat_my_medium)
    assert_response :success
  end

  test 'update ok' do
    patch my_medium_url(@wechat_my_medium), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Medium.count', -1) do
      delete my_medium_url(@wechat_my_medium)
    end

    assert_response :success
  end

end
