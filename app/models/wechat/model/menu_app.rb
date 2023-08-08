module Wechat
  module Model::MenuApp
    include Inner::Menu
    extend ActiveSupport::Concern

    included do
      attribute :appid, :string, index: true
      attribute :position, :integer

      belongs_to :menu, optional: true
      belongs_to :menu_root_app, optional: true
      belongs_to :app, foreign_key: :appid, primary_key: :appid

      belongs_to :scene, optional: true
      belongs_to :tag, optional: true
    end

  end
end
