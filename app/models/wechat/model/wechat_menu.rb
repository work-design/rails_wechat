module Wechat
  module RailsWechat::WechatMenu
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :menu_type, :string
      attribute :name, :string
      attribute :value, :string
      attribute :appid, :string
      attribute :mp_appid, :string
      attribute :mp_pagepath, :string
      attribute :position, :integer

      belongs_to :wechat_app, foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :parent, class_name: self.base_class.name, optional: true
      has_many :children, class_name: self.base_class.name, foreign_key: :parent_id, dependent: :nullify

      acts_as_list scope: [:parent_id, :appid]
    end

  end
end
