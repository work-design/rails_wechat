# frozen_string_literal: true

class Wechat::PublicApi
  module Common
    BASE = 'https://api.weixin.qq.com/cgi-bin/'

    def callbackip
      get 'getcallbackip', origin: BASE
    end

    def token
      r = client.with(origin: BASE).get 'token', params: { grant_type: 'client_credential', appid: app.appid, secret: app.secret }
      r.json
    end

    def jsapi_ticket
      get 'ticket/getticket', params: { type: 'jsapi' }, origin: BASE
    end

    # see: https://developers.weixin.qq.com/doc/offiaccount/Message_Management/API_Call_Limits.html
    def clear_quota
      post 'clear_quota', appid: app.appid, origin: BASE
    end

    def qrcode_create_scene(scene_id_or_str, expire_seconds = 2592000)
      case scene_id_or_str
      when 0.class
        post 'qrcode/create', expire_seconds: expire_seconds, action_name: 'QR_SCENE', action_info: { scene: { scene_id: scene_id_or_str } }, origin: BASE
      else
        post 'qrcode/create', expire_seconds: expire_seconds, action_name: 'QR_STR_SCENE', action_info: { scene: { scene_str: scene_id_or_str } }, origin: BASE
      end
    end

    def qrcode_create_limit_scene(scene_id_or_str)
      case scene_id_or_str
      when 0.class
        post 'qrcode/create', action_name: 'QR_LIMIT_SCENE', action_info: { scene: { scene_id: scene_id_or_str } }, origin: BASE
      else
        post 'qrcode/create', action_name: 'QR_LIMIT_STR_SCENE', action_info: { scene: { scene_str: scene_id_or_str } }, origin: BASE
      end
    end

    def shorturl(long_url)
      post 'shorturl', action: 'long2short', long_url: long_url, origin: BASE
    end

    # https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Batch_Sends_and_Originality_Checks.html
    def media_uploadimg(file)
      post_file 'media/uploadimg', file, origin: BASE
    end

    # https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Batch_Sends_and_Originality_Checks.html
    def media_uploadnews(mpnews_message)
      post 'media/uploadnews', mpnews_message, origin: BASE
    end

    def message_mass_delete(msg_id)
      post 'message/mass/delete', msg_id: msg_id, origin: BASE
    end

    def message_mass_preview(message)
      post 'message/mass/preview', message, origin: BASE
    end

    def message_mass_get(msg_id)
      post 'message/mass/get', msg_id: msg_id, origin: BASE
    end

  end
end
