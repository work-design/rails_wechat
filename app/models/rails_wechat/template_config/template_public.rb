module RailsWechat::TemplateConfig::TemplatePublic
  extend ActiveSupport::Concern
  included do

  end

  def data_hash
    r = {}
    template_key_words.where.not(mapping: [nil, '']).map do |i|
      r.merge! "#{i.rule}#{i.kid}" => { value: i.mapping, color: i.color}
    end

    r
  end

  def sync_key_words
    app = WechatPublic.default
    return unless app

    result = app.api.add_template tid
    template_id = result['template_id']
    return unless template_id

    template = app.api.templates.find { |i| i['template_id'] == template_id }
    data_keys = WechatTemplate.new(content: template['content']).data_keys
    data_keys.each do |key|
      tkw = template_key_words.find_or_initialize_by(name: key)
      tkw.save
    end

    app.api.del_template template_id
  end

end
