module RailsWechat::PublicTemplate
  extend ActiveSupport::Concern

  included do
    attribute :title, :string
    attribute :tid, :string
    attribute :kid_list, :integer, array: true, default: []
    attribute :description, :string
    attribute :notifiable_type, :string
    attribute :code, :string, default: 'default'
    attribute :mappings, :json, default: {}
  end
  
  def key_words
    app = WechatProgram.default
    return [] unless app
    app.api.template_key_words tid
  end

  def notify_setting
    r = RailsNotice.notifiable_types.dig(notifiable_type, self.code.to_sym) || {}
    r.fetch(:only, []).map(&->(o){ [notifiable_type.constantize.human_attribute_name(o), o] }).to_h
  end
  
end
