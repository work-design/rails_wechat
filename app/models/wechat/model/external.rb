module Wechat
  module Model::External
    extend ActiveSupport::Concern

    included do
      attribute :userid, :string
      attribute :corp_id, :string
      attribute :name, :string
      attribute :avatar, :string
      attribute :remark, :string
      attribute :state, :string
      attribute :external_userid, :string
      attribute :gender, :string
      attribute :description, :string
      attribute :add_way, :string

      belongs_to :corp_user, foreign_key: :userid, primary_key: :user_id

      belongs_to :crm_tag, class_name: 'Crm::Tag', foreign_key: :state, primary_key: :name, optional: true
    end

  end
end
