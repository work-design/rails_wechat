require 'test_helper'
class Wechat::Admin::ExtractorsControllerTest < ActionDispatch::IntegrationTest
 
  setup do
    @extractor = create :extractor
  end

  test 'index ok' do
    get admin_extractors_url
    assert_response :success
  end

  test 'new ok' do
    get new_admin_extractor_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('Extractor.count') do
      post admin_extractors_url, params: { extractor: { name: 'test' } }
    end

    assert_redirected_to wechat_admin_extractor_url(Extractor.last)
  end

  test 'show ok' do
    get admin_extractor_url(@extractor)
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_extractor_url(@extractor)
    assert_response :success
  end

  test 'update ok' do
    patch admin_extractor_url(@extractor), params: { extractor: { name: 'test' } }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Extractor.count', -1) do
      delete admin_extractor_url(@extractor)
    end

    assert_response :success
  end
end
