module Wechat
  module Model::MenuDisable
    extend ActiveSupport::Concern

    included do
      attribute :appid, :string

      belongs_to :menu
      belongs_to :app, foreign_key: :appid, primary_key: :appid
    end

  end
end
