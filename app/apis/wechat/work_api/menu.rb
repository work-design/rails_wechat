class Wechat::WorkApi
  module Menu
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/'

    def menu
      get 'menu/get', origin: BASE, agentid: @agentid
    end

    def menu_delete
      get 'menu/delete', origin: BASE, agentid: @agentid
    end

    def menu_create(menu)
      # 微信不接受7bit escaped json(eg \uxxxx), 中文必须UTF-8编码, 这可能是个安全漏洞
      post 'menu/create', menu, params: { agentid: @agentid }, origin: BASE
    end

    def material_count
      get 'material/get_count', params: { agentid: @agentid }, origin: BASE
    end

    def material_list(type, offset, count)
      post 'material/batchget', type: type, agentid: @agentid, offset: offset, count: count, origin: BASE
    end

    def material(media_id)
      get 'material/get', as: :file, origin: BASE, media_id: media_id, agentid: @agentid
    end

    def material_add(type, file)
      post_file 'material/add_material', file, params: { type: type, agentid: @agentid }, origin: BASE
    end

    def material_delete(media_id)
      get 'material/del', origin: BASE, media_id: media_id, agentid: @agentid
    end

    def message_send(userid, message)
      post 'message/send', Message.to(userid).text(message).agent_id(@agentid), origin: BASE
    end

    def custom_message_send(message)
      post 'message/send', message.is_a?(Wechat::Message) ? message.agent_id(@agentid).as_json : message.merge(agent_id: @agentid)
    end

  end
end
