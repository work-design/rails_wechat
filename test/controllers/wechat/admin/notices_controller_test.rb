require 'test_helper'
class Wechat::Admin::NoticesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @notice = create :notice
  end

  test 'index ok' do
    get admin_notices_url
    assert_response :success
  end

  test 'new ok' do
    get new_admin_notice_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('Notice.count') do
      post admin_notices_url, params: {  }
    end

    assert_response :success
  end

  test 'show ok' do
    get admin_notice_url(@notice)
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_notice_url(@notice)
    assert_response :success
  end

  test 'update ok' do
    patch admin_notice_url(@notice), params: {  }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Notice.count', -1) do
      delete admin_notice_url(@notice)
    end

    assert_response :success
  end

end
