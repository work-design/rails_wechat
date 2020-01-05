module RailsWechat::TemplateConfig::TemplateProgram
  extend ActiveSupport::Concern
  included do

  end

  def data_hash
    r = {}
    template_key_words.where.not(mapping: [nil, '']).map do |i|
      r.merge! "#{i.rule}#{i.kid}" => { value: i.mapping }
    end

    r
  end

end
