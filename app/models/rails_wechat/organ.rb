module RailsWechat::Organ
  extend ActiveSupport::Concern
  
  included do
    attribute :limit_wechat, :integer, default: 1
    attribute :limit_wechat_menu, :integer, default: 1
    has_many :wechat_configs, dependent: :destroy
    has_many :wechat_tags, dependent: :destroy
    
    validates :limit_wechat_menu, inclusion: { in: [1, 2] }
  end
  
  def sync_wechat_tags
    wechat_configs.each do |wechat_config|
      tags = wechat_config.api.tags
      tags.fetch('tags', []).each do |tag|
        wechat_tags.build(tag_id: tag['id'], tag_name: tag['name'], tag_count: tag['count'])
      end
    end
  end
  
end
