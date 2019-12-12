require 'test_helper'
class Wechat::My::WechatSubscribedsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @wechat_my_wechat_subscribed = create wechat_my_wechat_subscribeds
  end

  test 'index ok' do
    get my_wechat_subscribeds_url
    assert_response :success
  end

  test 'new ok' do
    get new_my_wechat_subscribed_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('WechatSubscribed.count') do
      post my_wechat_subscribeds_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_response :success
  end

  test 'show ok' do
    get my_wechat_subscribed_url(@wechat_my_wechat_subscribed)
    assert_response :success
  end

  test 'edit ok' do
    get edit_my_wechat_subscribed_url(@wechat_my_wechat_subscribed)
    assert_response :success
  end

  test 'update ok' do
    patch my_wechat_subscribed_url(@wechat_my_wechat_subscribed), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('WechatSubscribed.count', -1) do
      delete my_wechat_subscribed_url(@wechat_my_wechat_subscribed)
    end

    assert_response :success
  end

end
