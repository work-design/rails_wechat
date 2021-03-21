module Wechat
  module Model::App::WechatWork
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

    def wechat_corp_oauth2(oauth2_params, account = nil)
      userid   = cookies.signed_or_encrypted[:we_userid]
      deviceid = cookies.signed_or_encrypted[:we_deviceid]
      if userid.present? && deviceid.present?
        yield userid, { 'UserId' => userid, 'DeviceId' => deviceid }
      elsif params[:code].present? && params[:state] == oauth2_params[:state]
        userinfo = wechat(account).getuserinfo(params[:code])
        cookies.signed_or_encrypted[:we_userid] = { value: userinfo['UserId'], expires: self.class.oauth2_cookie_duration.from_now }
        cookies.signed_or_encrypted[:we_deviceid] = { value: userinfo['DeviceId'], expires: self.class.oauth2_cookie_duration.from_now }
        yield userinfo['UserId'], userinfo
      else
        redirect_to generate_oauth2_url(oauth2_params)
      end
    end

  end
end
