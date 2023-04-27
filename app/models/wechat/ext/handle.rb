module Wechat
  module Ext::Handle
    extend ActiveSupport::Concern

    included do
      has_one :scene, ->(o) { where(appid: o.appid) }, as: :handle, class_name: 'Wechat::Scene'

      has_many :scenes, as: :handle, class_name: 'Wechat::Scene'
    end

    def invite_scene!(app, organ_id: nil)
      scene = scenes.find_or_initialize_by(appid: app.appid, organ_id: organ_id)
      scene.refresh if scene.expired?
      scene.save
      scene
    end

    def to_scene!
      return unless respond_to?(:appid) && appid
      scene || build_scene
      scene.refresh if scene.expired?
      scene.save
      scene
    end


  end
end
