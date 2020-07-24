module Wechat::Api::Program::Wxapi
  WXAAPI =        'https://api.weixin.qq.com/wxaapi/'

  # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/template-message/templateMessage.getTemplateList.html
  def templates
    r = get 'newtmpl/gettemplate', base: WXAAPI
    if r['errcode'] === 0
      r['data']
    else
      Rails.logger.info r
      []
    end
  end

  # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/subscribe-message/subscribeMessage.getPubTemplateKeyWordsById.html
  def template_key_words(tid)
    r = get 'newtmpl/getpubtemplatekeywords', params: { tid: tid }, base: WXAAPI
    r['data']
  end

  def add_template(tid, kid_list, description: 'tst')
    post 'newtmpl/addtemplate', { tid: tid, kidList: kid_list, sceneDesc: description }, base: WXAAPI
  end

  def del_template(template_id)
    post 'newtmpl/deltemplate', {}, params: { priTmplId: template_id }, base: WXAAPI
  end


end
