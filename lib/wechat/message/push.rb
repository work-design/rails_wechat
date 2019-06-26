class Wechat::Message::Push
  
  TEMPLATE_KEYS = [
    'template_id',
    'form_id',
    'page',
    'color',
    'emphasis_keyword',
    'topcolor',
    'url',
    'miniprogram',
    'data'
  ].freeze
  
  def template(opts = {})
    template_fields = opts.symbolize_keys.slice(*TEMPLATE_KEYS)
    update(MsgType: 'template', Template: template_fields)
  end
  
  def to(to_users = '', towxname: nil, send_ignore_reprint: 0)
    if towxname.present?
      new(ToWxName: towxname, CreateTime: Time.now.to_i)
    elsif send_ignore_reprint == 1
      new(ToUserName: to_users, CreateTime: Time.now.to_i, send_ignore_reprint: send_ignore_reprint)
    else
      new(ToUserName: to_users, CreateTime: Time.now.to_i)
    end
  end
  
  def to_party(party)
    new(ToPartyName: party, CreateTime: Time.now.to_i)
  end
  
  def to_mass(tag_id: nil, send_ignore_reprint: 0)
    if tag_id
      new(filter: { is_to_all: false, tag_id: tag_id }, send_ignore_reprint: send_ignore_reprint)
    else
      new(filter: { is_to_all: true }, send_ignore_reprint: send_ignore_reprint)
    end
  end
  
end
