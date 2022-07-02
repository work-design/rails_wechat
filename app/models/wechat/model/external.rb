module Wechat
  module Model::External
    extend ActiveSupport::Concern

    included do
      attribute :corp_id, :string
      attribute :external_userid, :string
      attribute :name, :string
      attribute :position, :string
      attribute :avatar, :string
      attribute :corp_name, :string
      attribute :corp_full_name, :string
      attribute :external_type, :string
      attribute :gender, :string
      attribute :unionid, :string, index: true

      has_many :follows, ->(o){ where(corp_id: o.corp_id) }, class_name: 'Crm::Maintain', foreign_key: :external_userid, primary_key: :external_userid, inverse_of: :client, dependent: :delete_all
      has_many :wechat_users, primary_key: :unionid, foreign_key: :unionid
    end

  end
end
