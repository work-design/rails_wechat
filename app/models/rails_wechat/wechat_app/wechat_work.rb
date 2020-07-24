module RailsWechat::WechatApp::WechatWork
  extend ActiveSupport::Concern

  included do
    validates :agentid, presence: true
    alias_attribute :corpid, :appid
    alias_attribute :corpsecret, :secret
  end

  def api
    return @api if defined? @api
    @api = Wechat::Api::Work.new(self)
  end

end
