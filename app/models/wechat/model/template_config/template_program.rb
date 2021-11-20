module Wechat
  module Model::TemplateConfig::TemplateProgram
    extend ActiveSupport::Concern

    included do
    end

    def data_hash
      r = {}
      template_key_words.where.not(mapping: [nil, '']).each do |i|
        r.merge! "#{i.rule}#{i.kid}" => { value: i.mapping }
      end

      r
    end

    def sync_key_words
      return unless app
      key_words = app.api.template_key_words tid
      key_words.each do |kw|
        tkw = template_key_words.find_or_initialize_by(kid: kw['kid'])
        tkw.name = kw['name']
        tkw.example = kw['example']
        tkw.rule = kw['rule']
        tkw.save
      end
    end

  end
end
