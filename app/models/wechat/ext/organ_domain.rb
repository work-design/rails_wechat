module Wechat
  module Ext::OrganDomain
    extend ActiveSupport::Concern

    included do
      has_one :corp, class_name: 'Wechat::Corp', primary_key: :identifier, foreign_key: :host
      has_one :app, class_name: 'Wechat::PublicApp', primary_key: :identifier, foreign_key: :domain

      has_many :app_payees, class_name: 'Wechat::AppPayee', primary_key: :identifier, foreign_key: :domain
    end

  end
end

