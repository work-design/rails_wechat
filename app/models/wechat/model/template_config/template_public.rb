module Wechat
  module Model::TemplateConfig::TemplatePublic
    extend ActiveSupport::Concern

    included do
      validates :tid, presence: true
    end

    def data_hash
      r = {}
      template_key_words.each do |i|
        r.merge! i.name => { value: i.mapping, color: i.color }
      end

      r
    end

    def sync_key_words(app)
      template = app.api.templates.find { |i| i['template_id'] == tid }
      if template.blank?
        result = app.api.add_template tid
        binding.b
        template = app.api.templates.find { |i| i['template_id'] == result['template_id'] }
        #app.api.del_template result['template_id']
        self.update content: template['content']
      end

      return if content.blank?
      data_keys = Template.new(content: content).data_keys
      data_keys.each do |key|
        tkw = template_key_words.find_or_initialize_by(name: key)
        tkw.save
      end
    end

  end
end
