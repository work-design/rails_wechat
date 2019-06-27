class Ticket < ApplicationRecord
  include RailsWechat::Ticket
end unless defined? Ticket
