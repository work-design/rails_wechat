# frozen_string_literal: true

module Wechat::Api
  class Public < Common
    
    # https://developers.weixin.qq.com/doc/offiaccount/User_Management/User_Tag_Management.html
    def tags
      get 'tags/get'
    end
  
    def tag_create(tag_name, tag_id = nil)
      if tag_id.present?
        r = post 'tags/update', { tag: { id: tag_id, name: tag_name } }.to_json
        if r['errcode'] == 0
          { 'tag' => { 'id' => tag_id, 'name' => tag_name } }
        else
          r
        end
      else
        post 'tags/create', { tag: { name: tag_name } }.to_json
      end
    rescue Wechat::ResponseError => e
      if e.error_code == 45157
        { 'tag' => tags['tags'].find { |i| i['name'] == tag_name } }
      end
    end
  
    def tag_delete(tagid)
      post 'tags/delete', tag: { id: tagid }
    end
  
    def tag_add_user(tagid, *openids)
      post 'tags/members/batchtagging', openid_list: openids, tagid: tagid
    end
  
    def tag_del_user(tagid, *openids)
      post 'tags/members/batchuntagging', openid_list: openids, tagid: tagid
    end

    def tag(tagid, next_openid = '')
      post 'user/tag/get', tagid: tagid, next_openid: next_openid
    end
    
    def template_message_send(message)
      post 'message/template/send', message, headers: { content_type: :json }
    end

    def list_message_template
      get 'template/get_all_private_template'
    end

    def add_message_template(template_id_short)
      post 'template/api_add_template', template_id_short: template_id_short
    end

    def del_message_template(template_id)
      post 'template/del_private_template', template_id: template_id
    end
    
  end
end
