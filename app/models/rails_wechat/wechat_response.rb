module RailsWechat::Response
  extend ActiveSupport::Concern
  included do
    attribute :regexp, :string
    
  end
  
end
