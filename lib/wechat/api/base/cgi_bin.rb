# frozen_string_literal: true

module Wechat::Api::Base::CgiBin
  API_BASE = 'https://api.weixin.qq.com/cgi-bin/'

  def callbackip
    get 'getcallbackip'
  end

  # see: https://developers.weixin.qq.com/doc/offiaccount/Message_Management/API_Call_Limits.html
  def clear_quota
    post 'clear_quota', appid: app.appid
  end

  def users(nextid = nil)
    params = {}
    params.merge! next_openid: nextid if nextid.present?
    get 'user/get', params: params
  end

  def user(openid)
    get 'user/info', params: { openid: openid }
  end

  def user_batchget(openids, lang = 'zh-CN')
    post 'user/info/batchget', user_list: openids.collect { |v| { openid: v, lang: lang } }
  end

  def user_group(openid)
    post 'groups/getid', openid: openid
  end

  def user_change_group(openid, to_groupid)
    post 'groups/members/update', openid: openid, to_groupid: to_groupid
  end

  def user_update_remark(openid, remark)
    post 'user/info/updateremark', openid: openid, remark: remark
  end

  def qrcode_create_scene(scene_id_or_str, expire_seconds = 2592000)
    case scene_id_or_str
    when 0.class
      post 'qrcode/create', expire_seconds: expire_seconds, action_name: 'QR_SCENE', action_info: { scene: { scene_id: scene_id_or_str } }
    else
      post 'qrcode/create', expire_seconds: expire_seconds, action_name: 'QR_STR_SCENE', action_info: { scene: { scene_str: scene_id_or_str } }
    end
  end

  def qrcode_create_limit_scene(scene_id_or_str)
    case scene_id_or_str
    when 0.class
      post 'qrcode/create', action_name: 'QR_LIMIT_SCENE', action_info: { scene: { scene_id: scene_id_or_str } }
    else
      post 'qrcode/create', action_name: 'QR_LIMIT_STR_SCENE', action_info: { scene: { scene_str: scene_id_or_str } }
    end
  end

  def shorturl(long_url)
    post 'shorturl', action: 'long2short', long_url: long_url
  end

  # https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Batch_Sends_and_Originality_Checks.html
  def media_uploadimg(file)
    post_file 'media/uploadimg', file
  end

  # https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Batch_Sends_and_Originality_Checks.html
  def media_uploadnews(mpnews_message)
    post 'media/uploadnews', mpnews_message
  end


  def message_mass_delete(msg_id)
    post 'message/mass/delete', msg_id: msg_id
  end

  def message_mass_preview(message)
    post 'message/mass/preview', message
  end

  def message_mass_get(msg_id)
    post 'message/mass/get', msg_id: msg_id
  end

  def wxa_create_qrcode(path, width = 430)
    post 'wxaapp/createwxaqrcode', path: path, width: width
  end

  def media(media_id)
    get 'media/get', params: { media_id: media_id }, as: :file
  end

  def media_hq(media_id)
    get 'media/get/jssdk', params: { media_id: media_id }, as: :file
  end

  def media_create(type, file)
    post_file 'media/upload', file, params: { type: type }
  end

  def material(media_id)
    get 'material/get', params: { media_id: media_id }, as: :file
  end

  def material_count
    get 'material/get_materialcount'
  end

  def material_list(type = 'news', offset = 0, count = 20)
    post 'material/batchget_material', type: type, offset: offset, count: count
  end

  def material_add(type, file)
    post_file 'material/add_material', file, params: { type: type }
  end

  def material_add_news(*news)
    post 'material/add_news', articles: news
  end

  def material_delete(media_id)
    post 'material/del_material', media_id: media_id
  end

  def message_custom_send(message)
    post 'message/custom/send', message
  end

  def message_custom_typing(openid, command = 'Typing')
    post 'message/custom/typing', touser: openid, command: command
  end

  def customservice_getonlinekflist
    get 'customservice/getonlinekflist'
  end

end
