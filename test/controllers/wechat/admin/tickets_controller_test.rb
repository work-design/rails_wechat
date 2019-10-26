require 'test_helper'
class Wechat::Admin::TicketsControllerTest < ActionDispatch::IntegrationTest
 
  setup do
    @ticket = create :ticket
  end

  test 'index ok' do
    get admin_tickets_url
    assert_response :success
  end

  test 'new ok' do
    get new_admin_ticket_url, xhr: true
    assert_response :success
  end

  test 'create ok' do
    assert_difference('Ticket.count') do
      post admin_tickets_url, params: { ticket: { match_value: 'test' } }
    end

    assert_response :success
  end

  test 'show ok' do
    get admin_ticket_url(@ticket), xhr: true
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_ticket_url(@ticket), xhr: true
    assert_response :success
  end

  test 'update ok' do
    patch admin_ticket_url(@ticket), params: { ticket: { match_value: 'test1' } }, xhr: true
    
    @ticket.reload
    assert_equal 'test1', @ticket.match_value
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Ticket.count', -1) do
      delete admin_ticket_url(@ticket), xhr: true
    end

    assert_response :success
  end
end
