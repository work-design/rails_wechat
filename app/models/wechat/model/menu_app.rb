module Wechat
  module Model::MenuApp
    extend ActiveSupport::Concern

    included do
      attribute :appid, :string, index: true
      attribute :name, :string

      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :scene, optional: true
      belongs_to :tag, optional: true
      belongs_to :menu
    end

  end
end
