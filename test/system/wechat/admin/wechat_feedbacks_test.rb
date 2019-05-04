require "application_system_test_case"

class WechatFeedbacksTest < ApplicationSystemTestCase
  setup do
    @wechat_admin_wechat_feedback = wechat_admin_wechat_feedbacks(:one)
  end

  test "visiting the index" do
    visit wechat_admin_wechat_feedbacks_url
    assert_selector "h1", text: "Wechat Feedbacks"
  end

  test "creating a Wechat feedback" do
    visit wechat_admin_wechat_feedbacks_url
    click_on "New Wechat Feedback"

    fill_in "Body", with: @wechat_admin_wechat_feedback.body
    fill_in "Feedback on", with: @wechat_admin_wechat_feedback.feedback_on
    fill_in "Kind", with: @wechat_admin_wechat_feedback.kind
    fill_in "Wechat user", with: @wechat_admin_wechat_feedback.wechat_user_id
    click_on "Create Wechat feedback"

    assert_text "Wechat feedback was successfully created"
    click_on "Back"
  end

  test "updating a Wechat feedback" do
    visit wechat_admin_wechat_feedbacks_url
    click_on "Edit", match: :first

    fill_in "Body", with: @wechat_admin_wechat_feedback.body
    fill_in "Feedback on", with: @wechat_admin_wechat_feedback.feedback_on
    fill_in "Kind", with: @wechat_admin_wechat_feedback.kind
    fill_in "Wechat user", with: @wechat_admin_wechat_feedback.wechat_user_id
    click_on "Update Wechat feedback"

    assert_text "Wechat feedback was successfully updated"
    click_on "Back"
  end

  test "destroying a Wechat feedback" do
    visit wechat_admin_wechat_feedbacks_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Wechat feedback was successfully destroyed"
  end
end
