module Wechat
  module Model::Organ
    extend ActiveSupport::Concern

    included do
      attribute :limit_wechat, :integer, default: 1
      attribute :limit_wechat_menu, :integer, default: 1
      has_many :apps, class_name: 'Wechat::WechatApp', dependent: :destroy

      validates :limit_wechat_menu, inclusion: { in: [1, 2, 3] }
    end

  end
end
