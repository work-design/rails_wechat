require 'test_helper'
class Wechat::My::RegistersControllerTest < ActionDispatch::IntegrationTest

  setup do
    @register = create registers
  end

  test 'index ok' do
    get my_registers_url
    assert_response :success
  end

  test 'new ok' do
    get new_my_register_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('Register.count') do
      post my_registers_url, params: { }
    end

    assert_response :success
  end

  test 'show ok' do
    get my_register_url(@register)
    assert_response :success
  end

  test 'edit ok' do
    get edit_my_register_url(@register)
    assert_response :success
  end

  test 'update ok' do
    patch my_register_url(@register), params: { }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Register.count', -1) do
      delete my_register_url(@register)
    end

    assert_response :success
  end

end
