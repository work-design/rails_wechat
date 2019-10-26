require 'test_helper'
class Wechat::Admin::WechatTagsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @wechat_tag = create :wechat_tag
  end

  test 'index ok' do
    get admin_wechat_app_wechat_tags_url(@wechat_tag.wechat_app)
    assert_response :success
  end

  test 'new ok' do
    get new_admin_wechat_app_wechat_tag_url(@wechat_tag.wechat_app), xhr: true
    assert_response :success
  end

  test 'create ok' do
    assert_difference('WechatTag.count') do
      post admin_wechat_app_wechat_tags_url(@wechat_tag.wechat_app), params: { wechat_tag: { tag_id: 1, name: 'test' } }, xhr: true
    end

    assert_response :success
  end

  test 'show ok' do
    get admin_wechat_app_wechat_tag_url(@wechat_tag.wechat_app, @wechat_tag), xhr: true
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_wechat_app_wechat_tag_url(@wechat_tag.wechat_app, @wechat_tag), xhr: true
    assert_response :success
  end

  test 'update ok' do
    patch admin_wechat_app_wechat_tag_url(@wechat_tag.wechat_app, @wechat_tag), params: { wechat_tag: { tag_id: 1, name: 'test' } }, xhr: true
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('WechatTag.count', -1) do
      delete admin_wechat_app_wechat_tag_url(@wechat_tag.wechat_app, @wechat_tag), xhr: true
    end
    
    assert_response :success
  end
  
end
