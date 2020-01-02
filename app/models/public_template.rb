class PublicTemplate < ApplicationRecord
  include RailsWechat::PublicTemplate
end unless defined? PublicTemplate
