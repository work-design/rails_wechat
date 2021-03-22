require 'test_helper'
class Wechat::Admin::TemplatesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @template = create :template
  end

  test 'index ok' do
    get admin_templates_url
    assert_response :success
  end

  test 'new ok' do
    get new_admin_template_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('Template.count') do
      post admin_templates_url, params: {  }
    end

    assert_response :success
  end

  test 'show ok' do
    get admin_template_url(@template)
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_template_url(@template)
    assert_response :success
  end

  test 'update ok' do
    patch admin_template_url(@template), params: {  }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Template.count', -1) do
      delete admin_template_url(@template)
    end

    assert_response :success
  end

end
