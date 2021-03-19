module Wechat
  module Model::SceneMenu
    extend ActiveSupport::Concern

    included do
      belongs_to :scene
      belongs_to :wechat_tag, optional: true
      belongs_to :wechat_menu
    end

  end
end
