module Wechat
  module Ext::OrganDomain
    extend ActiveSupport::Concern

    included do
      has_one :corp, class_name: 'Wechat::Corp', primary_key: :identifier, foreign_key: :host
    end

  end
end

