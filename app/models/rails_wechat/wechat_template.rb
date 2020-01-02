module RailsWechat::WechatTemplate
  extend ActiveSupport::Concern

  included do
    attribute :template_id, :string
    attribute :title, :string
    attribute :content, :string
    attribute :example, :string
    attribute :template_type, :integer

    belongs_to :wechat_app
    belongs_to :public_template
    has_many :wechat_notices, dependent: :delete_all

    before_create :sync_to_wechat
  end

  def sync_to_wechat
    r = wechat_app.api.add_template(public_template.tid, public_tempate.kid_list)
    logger.debug(r['errmsg'])
    if r['errcode'] == 0
      self.template_id = r['priTmplId']
    end
  end

  def sync_to_wechat!
    sync_to_wechat
    save
  end

  def messenger
    wechat_app.template_messenger(self)
  end

  def data_keys
    content.gsub(/(?<={{)\w+(?=.DATA}})/).to_a
  end

end
