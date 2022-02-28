module Wechat
  module Model::Menu::ParentMenu
    extend ActiveSupport::Concern

    def as_json
      {
        name: name,
        sub_button: children.order(position: :desc).as_json
      }
    end

  end
end
