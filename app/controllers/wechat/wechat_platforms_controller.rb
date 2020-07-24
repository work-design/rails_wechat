class Wechat::WechatPlatformsController < Wechat::BaseController
  before_action :set_wechat_platform, only: [:show, :callback]

  def show
  end

  def callback
    @wechat_auth = @wechat_platform.wechat_auths.build
    @wechat_auth.auth_code = params[:auth_code]
    @wechat_auth.auth_code_expires_at = Time.current + params[:expires_in].to_i
    @wechat_auth.save
  end

  private
  def set_wechat_platform
    @wechat_platform = WechatPlatform.find(params[:id])
  end

end
