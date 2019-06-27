require 'test_helper'

class Wechat::Admin::TicketsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @wechat_admin_ticket = create wechat_admin_tickets
  end

  test 'index ok' do
    get admin_tickets_url
    assert_response :success
  end

  test 'new ok' do
    get new_admin_ticket_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('Ticket.count') do
      post admin_tickets_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_redirected_to wechat_admin_ticket_url(Ticket.last)
  end

  test 'show ok' do
    get admin_ticket_url(@wechat_admin_ticket)
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_ticket_url(@wechat_admin_ticket)
    assert_response :success
  end

  test 'update ok' do
    patch admin_ticket_url(@wechat_admin_ticket), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_redirected_to wechat_admin_ticket_url(@#{singular_table_name})
  end

  test 'destroy ok' do
    assert_difference('Ticket.count', -1) do
      delete admin_ticket_url(@wechat_admin_ticket)
    end

    assert_redirected_to admin_tickets_url
  end
end
