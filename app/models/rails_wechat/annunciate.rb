module RailsWechat::Annunciate
  extend ActiveSupport::Concern
  included do
    
    after_create_commit :to_wechat_later
  end
  
  def to_wechat_later
    WechatAnnunciateJob.perform_later(self)
  end

  def to_wechat
    apps = WechatPublic.valid.where(organ_id: annunciation.organ_id)
    apps.map do |app|
      tag_ids = app.wechat_tags.where(user_tag_id: user_tag_id).pluck(:tag_id)
      app.api.message_mass_sendall(body, tag_ids)
    end
  end
  
  def body
    annunciation.body
  end
  
end
