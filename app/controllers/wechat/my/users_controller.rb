class Wechat::My::UsersController < Wechat::My::BaseController

  def invite_qrcode
    if ENV['DEV_WECHAT']
      @appid = Rails.application.credentials.dig(:dev_wechat, :appid)
    else
      @appid = Rails.application.credentials.dig(:wechat, :appid)
    end

    @qrcode_url = current_user.invite_qrcode(@appid)
  end

end
