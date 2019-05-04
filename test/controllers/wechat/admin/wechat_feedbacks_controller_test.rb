require 'test_helper'

class Wechat::Admin::WechatFeedbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @wechat_admin_wechat_feedback = create wechat_admin_wechat_feedbacks
  end

  test 'index ok' do
    get admin_wechat_feedbacks_url
    assert_response :success
  end

  test 'new ok' do
    get new_admin_wechat_feedback_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('WechatFeedback.count') do
      post admin_wechat_feedbacks_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_redirected_to wechat_admin_wechat_feedback_url(WechatFeedback.last)
  end

  test 'show ok' do
    get admin_wechat_feedback_url(@wechat_admin_wechat_feedback)
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_wechat_feedback_url(@wechat_admin_wechat_feedback)
    assert_response :success
  end

  test 'update ok' do
    patch admin_wechat_feedback_url(@wechat_admin_wechat_feedback), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_redirected_to wechat_admin_wechat_feedback_url(@#{singular_table_name})
  end

  test 'destroy ok' do
    assert_difference('WechatFeedback.count', -1) do
      delete admin_wechat_feedback_url(@wechat_admin_wechat_feedback)
    end

    assert_redirected_to admin_wechat_feedbacks_url
  end
end
