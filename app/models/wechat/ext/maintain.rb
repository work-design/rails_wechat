module Wechat
  module Ext::Maintain
    extend ActiveSupport::Concern

    included do
      attribute :type, :string

      attribute :remark, :string
      attribute :state, :string
      attribute :oper_userid, :string
      attribute :add_way, :string
      attribute :external_userid, :string
      attribute :remark_mobiles, :json, default: []

      belongs_to :crm_tag, class_name: 'Crm::Tag', foreign_key: :state, primary_key: :name, optional: true
    end

  end
end
