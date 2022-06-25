module Wechat
  module Ext::Maintain
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :userid, :string

      attribute :remark, :string
      attribute :state, :string
      attribute :oper_userid, :string
      attribute :add_way, :string
      attribute :corp_id, :string
      attribute :external_userid, :string

      belongs_to :corp_user, ->(o){ where(corp_id: o.corp_id) }, foreign_key: :userid, primary_key: :user_id, optional: true
      belongs_to :external, ->(o){ where(corp_id: o.corp_id) }, foreign_key: :external_userid, primary_key: :external_userid

      belongs_to :crm_tag, class_name: 'Crm::Tag', foreign_key: :state, primary_key: :name, optional: true
    end

  end
end
