module RailsWechat::WechatTagDefault
  extend ActiveSupport::Concern
  included do
    attribute :name, :string
    attribute :default_type, :string

    has_many :wechat_tags, ->{ where(tagging_type: 'WechatTagDefault') }, foreign_key: :tagging_id, dependent: :nullify
  end
  
end

