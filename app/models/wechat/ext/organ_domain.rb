module Wechat
  module Ext::OrganDomain
    extend ActiveSupport::Concern

    included do
      has_one :corp, class_name: 'Wechat::Corp', primary_key: :host, foreign_key: :host
      has_one :app, class_name: 'Wechat::PublicApp', primary_key: :host, foreign_key: :domain

      has_many :payee_domains, class_name: 'Wechat::PayeeDomain', primary_key: :host, foreign_key: :domain
      has_many :payees, class_name: 'Wechat::Payee', through: :payee_domains
    end

  end
end

