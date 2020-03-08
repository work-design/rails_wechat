module RailsWechat::TemplateConfig::TemplatePublic
  extend ActiveSupport::Concern
  included do
  end

  def data_hash
    r = {}
    template_key_words.where.not(mapping: [nil, '']).each do |i|
      r.merge! i.name => { value: i.mapping, color: i.color }
    end

    r
  end

  def sync_key_words
    app = WechatPublic.default
    if tid.present? && app
      result = app.api.add_template tid
      template_id = result['template_id']
      app.api.del_template template_id
      template = app.api.templates.find { |i| i['template_id'] == template_id }
      self.update content: template['content']
    end

    data_keys = WechatTemplate.new(content: content).data_keys
    data_keys.each do |key|
      tkw = template_key_words.find_or_initialize_by(name: key)
      tkw.save
    end
  end

end
