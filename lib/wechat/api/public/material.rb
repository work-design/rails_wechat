module Wechat::Api::Public::Material
  BASE = 'https://api.weixin.qq.com/cgi-bin/'

  def media(media_id)
    get 'media/get', params: { media_id: media_id }, as: :file, base: BASE
  end

  def media_hq(media_id)
    get 'media/get/jssdk', params: { media_id: media_id }, as: :file, base: BASE
  end

  def media_create(type, file)
    post_file 'media/upload', file, params: { type: type }, base: BASE
  end

  def material(media_id)
    get 'material/get', params: { media_id: media_id }, as: :file, base: BASE
  end

  def material_count
    get 'material/get_materialcount', base: BASE
  end

  def material_list(type = 'news', offset = 0, count = 20)
    post 'material/batchget_material', type: type, offset: offset, count: count, base: BASE
  end

  def material_add(type, file)
    post_file 'material/add_material', file, params: { type: type }, base: BASE
  end

  def material_add_news(*news)
    post 'material/add_news', articles: news, base: BASE
  end

  def material_delete(media_id)
    post 'material/del_material', media_id: media_id, base: BASE
  end

  def message_custom_send(message)
    post 'message/custom/send', message, base: BASE
  end

  def message_custom_typing(openid, command = 'Typing')
    post 'message/custom/typing', touser: openid, command: command, base: BASE
  end

  def customservice_getonlinekflist
    get 'customservice/getonlinekflist', base: BASE
  end

end
