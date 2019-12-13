module RailsWechat::WechatSubscribed
  extend ActiveSupport::Concern

  included do
    attribute :sending_at, :datetime
    attribute :status, :string, default: 'accept'
    
    enum status: {
      accept: 'accept',
      reject: 'reject',
      ban: 'ban'
    }, _prefix: true
    
    belongs_to :wechat_user
    belongs_to :wechat_notice
    belongs_to :wechat_template
  end
  
end
