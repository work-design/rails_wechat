module Wechat
  class SceneRefreshJob < ApplicationJob

    def perform(scene)
      scene.refresh(true)
    end

  end
end
