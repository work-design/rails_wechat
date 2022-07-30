module Wechat
  module Model::TemplateConfig::TemplatePublic
    extend ActiveSupport::Concern

    included do
      after_save_commit :sync_keys, if: -> { content.present? && saved_change_to_content? }
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

    def sync_to_wechat(app)
      return if tid.blank?
      temp = app.api.templates.find { |i| i['content'] == content }
      if temp.blank?
        result = app.api.add_template tid
        app.sync_templates
        result
      else
        temp
      end
    end

    def sync_keys
      data_keys.each do |key|
        tkw = template_key_words.find_or_initialize_by(name: key)
        tkw.save
      end
    end

  end
end
