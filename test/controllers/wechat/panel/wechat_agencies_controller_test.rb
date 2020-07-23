require 'test_helper'
class Wechat::Panel::WechatAgenciesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @wechat_panel_wechat_agency = create wechat_panel_wechat_agencies
  end

  test 'index ok' do
    get panel_wechat_agencies_url
    assert_response :success
  end

  test 'new ok' do
    get new_panel_wechat_agency_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('WechatAgency.count') do
      post panel_wechat_agencies_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_response :success
  end

  test 'show ok' do
    get panel_wechat_agency_url(@wechat_panel_wechat_agency)
    assert_response :success
  end

  test 'edit ok' do
    get edit_panel_wechat_agency_url(@wechat_panel_wechat_agency)
    assert_response :success
  end

  test 'update ok' do
    patch panel_wechat_agency_url(@wechat_panel_wechat_agency), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('WechatAgency.count', -1) do
      delete panel_wechat_agency_url(@wechat_panel_wechat_agency)
    end

    assert_response :success
  end

end
