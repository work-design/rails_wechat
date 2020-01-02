module RailsWechat::PublicTemplate
  extend ActiveSupport::Concern
  included do
    attribute :title, :string
    attribute :tid, :string
    attribute :kid_list, :integer, array: true
    attribute :description, :string
  end
  
  def key_words
    api.template_key_words tid
  end
  
  
end
