module Wechat
  module Model::WechatTemplate
    extend ActiveSupport::Concern

    included do
      attribute :template_id, :string
      attribute :title, :string
      attribute :content, :string
      attribute :example, :string
      attribute :template_type, :integer

      belongs_to :app
      belongs_to :template_config, optional: true
      has_many :wechat_notices, dependent: :delete_all

      before_save :sync_from_template_config, if: -> { template_config_id_changed? || template_config }
      before_save :sync_to_wechat, if: -> { template_id_changed? && template_id.present? }
      after_destroy_commit :del_to_wechat
    end

    def init_template_config
      if app.is_a?(WechatPublic)
        config = TemplatePublic.find_or_initialize_by(content: content)
        config.title = title
        self.template_config = config
        self.save
      end
    end

    def sync_from_template_config
      self.template_id ||= template_config.tid
    end

    def sync_to_wechat
      sync_from_wechat
      return if content.present?
      r = app.api.add_template(template_config.tid, template_config.kid_list)
      if r['errcode'] == 0
        self.template_id = r['priTmplId'] || r['template_id']
      else
        logger.debug("  =========> Error is #{r['errmsg']}")
        return
      end
      sync_from_wechat
    end

    def sync_from_wechat
      r_content = app.api.templates.find do |i|
        tid = app.is_a?(WechatPublic) ? i['template_id'] : i['priTmplId']
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
      content.gsub(/(?<={{)\w+(?=.DATA}})/).to_a
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
