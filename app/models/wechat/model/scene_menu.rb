module Wechat
  module Model::SceneMenu
    extend ActiveSupport::Concern

    included do
      belongs_to :scene
      belongs_to :tag, optional: true
      belongs_to :menu
    end

  end
end
