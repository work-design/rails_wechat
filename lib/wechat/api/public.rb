# frozen_string_literal: true

module Wechat::Api
  class Public < Common

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
