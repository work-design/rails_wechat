module Wechat
  module Model::AppMenu
    extend ActiveSupport::Concern

    included do
      attribute :appid, :string

      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :scene
      belongs_to :tag, optional: true
      belongs_to :menu
    end

  end
end
