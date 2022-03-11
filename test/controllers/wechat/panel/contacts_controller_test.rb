require 'test_helper'
class Wechat::Panel::ContactsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @contact = contacts(:one)
  end

  test 'index ok' do
    get url_for(controller: 'wechat/panel/contacts')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'wechat/panel/contacts')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('Contact.count') do
      post(
        url_for(controller: 'wechat/panel/contacts', action: 'create'),
        params: { contact: { config_id: @wechat_panel_contact.config_id, corp_id: @wechat_panel_contact.corp_id, part_id: @wechat_panel_contact.part_id, qr_code: @wechat_panel_contact.qr_code, remark: @wechat_panel_contact.remark, skip_verify: @wechat_panel_contact.skip_verify, user_id: @wechat_panel_contact.user_id } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'wechat/panel/contacts', action: 'show', id: @contact.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'wechat/panel/contacts', action: 'edit', id: @contact.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'wechat/panel/contacts', action: 'update', id: @contact.id),
      params: { contact: { config_id: @wechat_panel_contact.config_id, corp_id: @wechat_panel_contact.corp_id, part_id: @wechat_panel_contact.part_id, qr_code: @wechat_panel_contact.qr_code, remark: @wechat_panel_contact.remark, skip_verify: @wechat_panel_contact.skip_verify, user_id: @wechat_panel_contact.user_id } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Contact.count', -1) do
      delete url_for(controller: 'wechat/panel/contacts', action: 'destroy', id: @contact.id), as: :turbo_stream
    end

    assert_response :success
  end

end
