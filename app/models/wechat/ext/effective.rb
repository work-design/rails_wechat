module Wechat
  module Ext::Effective
    extend ActiveSupport::Concern

    included do
      has_one :response, class_name: 'Wechat::Response', as: :effective
    end

  end
end
