require 'test_helper'
class Wechat::Admin::UserTagsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user_tag = user_tags(:one)
  end

  test 'index ok' do
    get url_for(controller: 'wechat/admin/user_tags')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'wechat/admin/user_tags')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('UserTag.count') do
      post(
        url_for(controller: 'wechat/admin/user_tags', action: 'create'),
        params: { user_tag: {  } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'wechat/admin/user_tags', action: 'show', id: @user_tag.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'wechat/admin/user_tags', action: 'edit', id: @user_tag.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'wechat/admin/user_tags', action: 'update', id: @user_tag.id),
      params: { user_tag: {  } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('UserTag.count', -1) do
      delete url_for(controller: 'wechat/admin/user_tags', action: 'destroy', id: @user_tag.id), as: :turbo_stream
    end

    assert_response :success
  end

end
