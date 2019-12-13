module RailsWechat::WechatTemplate
  extend ActiveSupport::Concern
  
  included do
    attribute :template_id, :string
    attribute :title, :string
    attribute :content, :string
    attribute :example, :string
    attribute :template_type, :integer
    
    belongs_to :wechat_app, optional: true
    has_many :wechat_notices, dependent: :delete_all
  end
  
  def messenger
    wechat_app.template_messenger(self)
  end
  
  def data_keys
    content.gsub(/(?<={{)\w+(?=.DATA}})/).to_a
  end

end
