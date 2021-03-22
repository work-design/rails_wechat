require 'test_helper'
class Wechat::My::SubscribedsControllerTest < ActionDispatch::IntegrationTest

  test 'create ok' do
    assert_difference('Subscribed.count') do
      post my_subscribes_url, params: { }
    end

    assert_response :success
  end


end
