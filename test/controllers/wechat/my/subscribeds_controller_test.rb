require 'test_helper'
class Wechat::My::SubscribedsControllerTest < ActionDispatch::IntegrationTest

  test 'create ok' do
    assert_difference('Subscribed.count') do
      post my_wechat_subscribeds_url, params: { }
    end

    assert_response :success
  end


end
