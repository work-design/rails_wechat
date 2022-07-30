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

      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :template_config, optional: true
      has_many :notices, dependent: :delete_all
      has_many :msg_requests, ->(o){ where(appid: o.appid) }, foreign_key: :body, primary_key: :template_id

      before_save :sync_to_wechat, if: -> { template_id_changed? && template_id.present? }
      after_destroy_commit :del_to_wechat
    end

    def init_template_config
      if app.is_a?(PublicApp)
        config = TemplatePublic.find_or_initialize_by(content: content)
        config.title = title
        self.template_config = config
        self.save
      end
    end

    def sync_to_wechat
      sync_from_wechat
      return if content.present?
      r = app.api.add_template(template_config.tid, template_config.kid_list)
      if r['errcode'] == 0
        self.template_id = r['priTmplId'] || r['template_id']
      else
        logger.debug("  Error is #{r['errmsg']}  ")
        return
      end
      sync_from_wechat
    end

    def sync_from_wechat
      r_content = app.api.templates.find do |i|
        tid = app.is_a?(PublicApp) ? i['template_id'] : i['priTmplId']
        tid == self.template_id
      end
      return if r_content.blank?
      self.template_type = r_content['type']
      self.assign_attributes r_content.slice('title', 'content', 'example')
      self
    end

    def sync_to_wechat!
      sync_to_wechat
      save
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
