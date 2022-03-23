module Wechat
  module Model::Follow
    extend ActiveSupport::Concern

    included do
      attribute :userid, :string
      attribute :remark, :string
      attribute :description, :string
      attribute :state, :string
      attribute :oper_userid, :string
      attribute :add_way, :string
      attribute :corp_id, :string
      attribute :external_userid, :string

      belongs_to :corp_user, foreign_key: :userid, primary_key: :user_id
      belongs_to :external, foreign_key: :external_userid, primary_key: :external_userid

      belongs_to :crm_tag, class_name: 'Crm::Tag', foreign_key: :state, primary_key: :name, optional: true
    end

  end
end
