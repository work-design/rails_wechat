module RailsWechat::User
  extend ActiveSupport::Concern

  included do
    has_many :wechat_users
    has_many :wechat_program_users
    has_many :wechat_subscribeds, ->{ where(sending_at: nil).order(id: :asc) }, through: :wechat_program_users
  end

  def invite_qrcode(appid)
    p = {
      appid: appid,
      match_value: "invite_by_#{id}"
    }
    res = WechatResponse.find_or_initialize_by(p)
    res.effective_type = 'TextReply'
    res.request_types = [
      'SubscribeRequest',
      'ScanRequest'
    ]
    res.expire_seconds = 2592000
    res.save
    res.qrcode_file_url
  end

end
