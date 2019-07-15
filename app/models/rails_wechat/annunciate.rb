module RailsWechat::Annunciate
  extend ActiveSupport::Concern
  included do
    
    after_create_commit :to_wechat_later
  end
  
  def to_wechat_later
    WechatAnnunciateJob.perform_later(self)
  end

  def to_wechat
    app = WechatPublic.valid.find_by(organ_id: annunciation.organ_id, primary: true)
    
    return unless app
    
    tag_ids = app.wechat_tags.where(user_tag_id: user_tag_id).pluck(:tag_id)
    if tag_ids.present?
      api = app.api
      tag_ids.each do |tag_id|
        api.message_mass_sendall(body, tag_id)
      end
    end
  end
  
  def body
    annunciation.body
  end
  
end
