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

    def data_keys
      r = RegexpUtil.between('{{', '.D(ATA|ata)}}')
      content.gsub(r).to_a
    end

    def sync_key_words(app)
      temp = app.api.templates.find { |i| i['content'] == content }
      if temp.blank?
        result = app.api.add_template tid
        temp = app.api.templates.find { |i| i['template_id'] == result['template_id'] }
        self.update content: temp['content']
      end

      template = templates.find_or_initialize_by(template_id: temp['template_id'])
      template.assign_attributes temp.slice('title', 'content', 'example')
      template.app = app
      template.save

      return if content.blank?
      data_keys.each do |key|
        tkw = template_key_words.find_or_initialize_by(name: key)
        tkw.save
      end
    end

  end
end
