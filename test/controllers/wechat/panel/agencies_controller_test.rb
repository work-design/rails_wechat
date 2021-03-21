require 'test_helper'
class Wechat::Panel::AgenciesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @wechat_panel_agency = create wechat_panel_agencies
  end

  test 'index ok' do
    get panel_agencies_url
    assert_response :success
  end

  test 'new ok' do
    get new_panel_wechat_agency_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('Agency.count') do
      post panel_agencies_url, params: { }
    end

    assert_response :success
  end

  test 'show ok' do
    get panel_wechat_agency_url(@agency)
    assert_response :success
  end

  test 'edit ok' do
    get edit_panel_wechat_agency_url(@agency)
    assert_response :success
  end

  test 'update ok' do
    patch panel_wechat_agency_url(@agency), params: { }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Agency.count', -1) do
      delete panel_wechat_agency_url(@agency)
    end

    assert_response :success
  end

end
