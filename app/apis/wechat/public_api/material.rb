class Wechat::PublicApi
  module Material
    BASE = 'https://api.weixin.qq.com/cgi-bin/'

    def media(media_id)
      get 'media/get', origin: BASE, as: :file, media_id: media_id
    end

    def media_hq(media_id)
      get 'media/get/jssdk', origin: BASE, media_id: media_id, as: :file
    end

    def media_create(file, type = 'image')
      post_file 'media/upload', file, params: { type: type }, origin: BASE
    end

    def material(media_id)
      get 'material/get', params: { media_id: media_id }, as: :file, origin: BASE
    end

    def material_count
      get 'material/get_materialcount', origin: BASE
    end

    def material_list(type = 'news', offset = 0, count = 20)
      post 'material/batchget_material', type: type, offset: offset, count: count, origin: BASE
    end

    def material_add(type, file)
      post_file 'material/add_material', file, params: { type: type }, origin: BASE
    end

    def material_add_news(*news)
      post 'material/add_news', articles: news, origin: BASE
    end

    def material_delete(media_id)
      post 'material/del_material', media_id: media_id, origin: BASE
    end

    def message_custom_send(message)
      post 'message/custom/send', **message, origin: BASE
    end

    def message_custom_typing(openid, command = 'Typing')
      post 'message/custom/typing', touser: openid, command: command, origin: BASE
    end

    def customservice_getonlinekflist
      get 'customservice/getonlinekflist', origin: BASE
    end

  end
end
