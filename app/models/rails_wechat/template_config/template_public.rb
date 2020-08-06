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

  def sync_key_words(app = WechatPublic.default)
    if tid.present? && app
      template = app.api.templates.find { |i| i['template_id'] == tid }
      if template.blank?
        result = app.api.add_template tid
        template = app.api.templates.find { |i| i['template_id'] == result['template_id'] }
        app.api.del_template result['template_id']
      end
      self.update content: template['content']
    end

    return if content.blank?
    data_keys = WechatTemplate.new(content: content).data_keys
    data_keys.each do |key|
      tkw = template_key_words.find_or_initialize_by(name: key)
      tkw.save
    end
  end

end
