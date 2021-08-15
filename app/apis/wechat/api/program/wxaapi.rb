module Wechat::Api
  module Program::Wxaapi
    BASE = 'https://api.weixin.qq.com/wxaapi/'

    # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/template-message/templateMessage.getTemplateList.html
    def templates
      r = get 'newtmpl/gettemplate', base: BASE
      if r['errcode'] === 0
        r['data']
      else
        Rails.logger.info r
        []
      end
    end

    # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/subscribe-message/subscribeMessage.getPubTemplateKeyWordsById.html
    def template_key_words(tid)
      r = get 'newtmpl/getpubtemplatekeywords', params: { tid: tid }, base: BASE
      r['data']
    end

    def add_template(tid, kid_list, description: 'tst')
      post 'newtmpl/addtemplate', tid: tid, kidList: kid_list, sceneDesc: description, base: BASE
    end

    def del_template(template_id)
      post 'newtmpl/deltemplate', params: { priTmplId: template_id }, base: BASE
    end

  end
end
