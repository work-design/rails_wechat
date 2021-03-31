module Wechat
  module Model::Media
    extend ActiveSupport::Concern

    included do
      attribute :media_id, :string
      attribute :appid, :string

      belongs_to :source, polymorphic: true, optional: true
      belongs_to :app, foreign_key: :appid, primary_key: :appid

      belongs_to :user, class_name: 'Auth::User'
    end

  end
end
