module Wechat
  module Ext::Handle
    extend ActiveSupport::Concern

    included do
      has_one :scene, ->(o) { where(appid: o.appid) }, as: :handle, class_name: 'Wechat::Scene'

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
