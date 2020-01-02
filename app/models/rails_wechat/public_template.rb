module RailsWechat::PublicTemplate
  extend ActiveSupport::Concern
  included do
    attribute :title, :string
    attribute :tid, :string
    attribute :kid_list, :integer, array: true, default: []
    attribute :description, :string
  end
  
  def key_words
    app = WechatProgram.default
    return [] unless app
    app.api.template_key_words tid
  end
  
  
end
