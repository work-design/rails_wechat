module Wechat
  module Model::Template
    extend ActiveSupport::Concern

    included do
      attribute :template_id, :string
      attribute :title, :string
      attribute :content, :string
      attribute :example, :string
      attribute :template_type, :integer
      attribute :appid, :string, index: true
      attribute :template_kind, :string

      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :template_config, foreign_key: :content, primary_key: :content, optional: true
      has_many :notices, dependent: :delete_all
      has_many :msg_requests, ->(o){ where(appid: o.appid) }, foreign_key: :body, primary_key: :template_id

      after_destroy_commit :del_to_wechat
      after_save_commit :init_template_config, if: -> { content.present? && saved_change_to_content? }
    end

    def init_template_config
      template_config || build_template_config
      template_config.title = title
      template_config.save
    end

    def del_to_wechat
      r = app.api.del_template(template_id)
      logger.debug(r['errmsg'])
    end

    def data_keys
      r = RegexpUtil.between('{{', '.D(ATA|ata)}}')
      content.gsub(r).to_a
    end

    def data_mappings
      if template_config
        template_config.data_hash
      else
        {}
      end
    end

  end
end
