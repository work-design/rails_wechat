require 'test_helper'
class Wechat::My::WechatSubscribedsControllerTest < ActionDispatch::IntegrationTest

  test 'create ok' do
    assert_difference('WechatSubscribed.count') do
      post my_wechat_subscribeds_url, params: { }
    end

    assert_response :success
  end


end
