module RailsWechat::WechatRequest
  extend ActiveSupport::Concern
  included do
    attribute :type, :string
    attribute :body, :text

    belongs_to :wechat_user
    belongs_to :wechat_app
    has_many :extractions, as: :extractable, inverse_of: :wechat_request  # 解析 request body 内容，主要针对文字
    has_many :ticket_items, dependent: :delete_all
  end

  def do_extract
  end

  def response
  end

end
