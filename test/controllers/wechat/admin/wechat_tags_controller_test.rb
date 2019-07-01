require 'test_helper'

class Wechat::Admin::WechatTagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @wechat_admin_wechat_tag = create wechat_admin_wechat_tags
  end

  test 'index ok' do
    get admin_wechat_tags_url
    assert_response :success
  end

  test 'new ok' do
    get new_admin_wechat_tag_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('WechatTag.count') do
      post admin_wechat_tags_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_redirected_to wechat_admin_wechat_tag_url(WechatTag.last)
  end

  test 'show ok' do
    get admin_wechat_tag_url(@wechat_admin_wechat_tag)
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_wechat_tag_url(@wechat_admin_wechat_tag)
    assert_response :success
  end

  test 'update ok' do
    patch admin_wechat_tag_url(@wechat_admin_wechat_tag), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_redirected_to wechat_admin_wechat_tag_url(@#{singular_table_name})
  end

  test 'destroy ok' do
    assert_difference('WechatTag.count', -1) do
      delete admin_wechat_tag_url(@wechat_admin_wechat_tag)
    end

    assert_redirected_to admin_wechat_tags_url
  end
end
