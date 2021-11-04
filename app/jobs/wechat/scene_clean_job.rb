module Wechat
  class SceneCleanJob < ApplicationJob

    def perform(scene)
      scene.destroy
    end

  end
end
