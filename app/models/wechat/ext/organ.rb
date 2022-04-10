module Wechat
  module Ext::Organ
    extend ActiveSupport::Concern

    included do
      attribute :limit_wechat, :integer, default: 1
      attribute :limit_wechat_menu, :integer, default: 1
      attribute :corp_id, :string

      has_many :apps, class_name: 'Wechat::App', dependent: :destroy_async
      has_many :corps, class_name: 'Wechat::Corp', primary_key: :corp_id, foreign_key: :corp_id

      validates :limit_wechat_menu, inclusion: { in: [1, 2, 3] }
    end

  end
end
