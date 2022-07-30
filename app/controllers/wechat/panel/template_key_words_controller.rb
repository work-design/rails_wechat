module Wechat
  class Panel::TemplateKeyWordsController < Panel::BaseController
    before_action :set_template_config

    def index
      @template_key_words = @template_config.template_key_words
    end

    private
    def set_template_config
      @template_config = TemplateConfig.find params[:template_config_id]
    end

    def set_new_template_key_word
      @template_key_word = @template_config.template_key_words.build(template_key_word_params)
    end

    def template_key_word_params
      params.fetch(:template_key_word, {}).permit(
        :name,
        :mapping,
        :color
      )
    end

  end
end
