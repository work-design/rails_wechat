require 'test_helper'
class Wechat::Admin::TemplateConfigsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @template_config = create template_configs
  end

  test 'index ok' do
    get admin_template_configs_url
    assert_response :success
  end

  test 'new ok' do
    get new_admin_template_config_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('PublicTemplate.count') do
      post admin_template_configs_url, params: {}
    end

    assert_response :success
  end

  test 'show ok' do
    get admin_template_config_url(@template_config)
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_template_config_url(@template_config)
    assert_response :success
  end

  test 'update ok' do
    patch admin_template_config_url(@template_config), params: {}
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('PublicTemplate.count', -1) do
      delete admin_template_config_url(@template_config)
    end

    assert_response :success
  end

end
