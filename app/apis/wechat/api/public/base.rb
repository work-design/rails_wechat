# frozen_string_literal: true

module Wechat::Api::Public::Base
  BASE = 'https://api.weixin.qq.com/cgi-bin/'

  def callbackip
    get 'getcallbackip', base: BASE
  end

  def token
    client.get 'token', params: { grant_type: 'client_credential', appid: app.appid, secret: app.secret }, base: BASE
  end

  def jsapi_ticket
    get 'ticket/getticket', params: { type: 'jsapi' }, base: BASE
  end

  # see: https://developers.weixin.qq.com/doc/offiaccount/Message_Management/API_Call_Limits.html
  def clear_quota
    post 'clear_quota', appid: app.appid, base: BASE
  end

  def qrcode_create_scene(scene_id_or_str, expire_seconds = 2592000)
    case scene_id_or_str
    when 0.class
      post 'qrcode/create', expire_seconds: expire_seconds, action_name: 'QR_SCENE', action_info: { scene: { scene_id: scene_id_or_str } }, base: BASE
    else
      post 'qrcode/create', expire_seconds: expire_seconds, action_name: 'QR_STR_SCENE', action_info: { scene: { scene_str: scene_id_or_str } }, base: BASE
    end
  end

  def qrcode_create_limit_scene(scene_id_or_str)
    case scene_id_or_str
    when 0.class
      post 'qrcode/create', action_name: 'QR_LIMIT_SCENE', action_info: { scene: { scene_id: scene_id_or_str } }, base: BASE
    else
      post 'qrcode/create', action_name: 'QR_LIMIT_STR_SCENE', action_info: { scene: { scene_str: scene_id_or_str } }, base: BASE
    end
  end

  def shorturl(long_url)
    post 'shorturl', action: 'long2short', long_url: long_url, base: BASE
  end

  # https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Batch_Sends_and_Originality_Checks.html
  def media_uploadimg(file)
    post_file 'media/uploadimg', file, base: BASE
  end

  # https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Batch_Sends_and_Originality_Checks.html
  def media_uploadnews(mpnews_message)
    post 'media/uploadnews', mpnews_message, base: BASE
  end


  def message_mass_delete(msg_id)
    post 'message/mass/delete', msg_id: msg_id, base: BASE
  end

  def message_mass_preview(message)
    post 'message/mass/preview', message, base: BASE
  end

  def message_mass_get(msg_id)
    post 'message/mass/get', msg_id: msg_id, base: BASE
  end

  def wxa_create_qrcode(path, width = 430)
    post 'wxaapp/createwxaqrcode', path: path, width: width, base: BASE
  end

end
