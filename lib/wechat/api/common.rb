# frozen_string_literal: true

class Wechat::Api::Common < Wechat::Api::Base
  WXA_BASE = 'https://api.weixin.qq.com/wxa/'
  API_BASE = 'https://api.weixin.qq.com/cgi-bin/'
  DATACUBE_BASE = 'https://api.weixin.qq.com/datacube/'
  SNS_BASE = 'https://api.weixin.qq.com/sns/'
  
  def initialize(app)
    @client = Wechat::HttpClient.new(API_BASE)
    @app = app
    @access_token = Wechat::AccessToken::Public.new(@client, app)
    @jsapi_ticket = Wechat::JsapiTicket::Public.new(@client, app, @access_token)
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
  
  def message_mass_sendall(message, tag_id)
    message = { content: message } if message.is_a? String
    
    push = Wechat::Message::Push::Public.new(message)
    push.to_mass(tag_id)
    
    post 'message/mass/sendall', push
  end
  
  def message_mass_send(message, *openid)
    message = { content: message } if message.is_a? String
  
    push = Wechat::Message::Push::Public.new(message)
    push.to(openid)
    
    post 'message/mass/send', push
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
  
  def material_delete(media_id)
    post 'material/del_material', media_id: media_id
  end
  
  def custom_message_send(message)
    post 'message/custom/send', message, headers: { content_type: :json }
  end
  
  def customservice_getonlinekflist
    get 'customservice/getonlinekflist'
  end
  
  def getusersummary(begin_date, end_date)
    post 'getusersummary', begin_date: begin_date, end_date: end_date, base: DATACUBE_BASE
  end
  
  def getusercumulate(begin_date, end_date)
    post 'getusercumulate', begin_date: begin_date, end_date: end_date, base: DATACUBE_BASE
  end

  def web_access_token(code)
    params = {
      appid: access_token.appid,
      secret: access_token.secret,
      code: code,
      grant_type: 'authorization_code'
    }
    get 'oauth2/access_token', params: params, base: SNS_BASE
  end

  def web_auth_access_token(web_access_token, openid)
    get 'auth', params: { access_token: web_access_token, openid: openid }, base: SNS_BASE
  end

  def web_refresh_access_token(user_refresh_token)
    params = {
      appid: access_token.appid,
      grant_type: 'refresh_token',
      refresh_token: user_refresh_token
    }
    get 'oauth2/refresh_token', params: params, base: SNS_BASE
  end

  def web_userinfo(web_access_token, openid, lang = 'zh_CN')
    get 'userinfo', params: { access_token: web_access_token, openid: openid, lang: lang }, base: SNS_BASE
  end
  
end
