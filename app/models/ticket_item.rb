class TicketItem < ApplicationRecord
  include RailsWechat::TicketItem
end unless defined? TicketItem
