require 'test_helper'
class Wechat::Admin::ExtractorsControllerTest < ActionDispatch::IntegrationTest
 
  setup do
    @wechat_admin_extractor = create wechat_admin_extractors
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
      post admin_extractors_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_redirected_to wechat_admin_extractor_url(Extractor.last)
  end

  test 'show ok' do
    get admin_extractor_url(@wechat_admin_extractor)
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_extractor_url(@wechat_admin_extractor)
    assert_response :success
  end

  test 'update ok' do
    patch admin_extractor_url(@wechat_admin_extractor), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Extractor.count', -1) do
      delete admin_extractor_url(@wechat_admin_extractor)
    end

    assert_response :success
  end
end
