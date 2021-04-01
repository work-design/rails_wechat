module Wechat
  module Model::Media
    extend ActiveSupport::Concern

    included do
      attribute :media_id, :string
      attribute :appid, :string
      attribute :attachment_name, :string

      belongs_to :source, polymorphic: true, optional: true, autosave: true
      belongs_to :app, foreign_key: :appid, primary_key: :appid

      belongs_to :user, class_name: 'Auth::User'

      after_create_commit :store_entity_later
    end

    def store_entity_later
      MediaJob.perform_later(self)
    end

    def store_entity
      r = app.api.media(media_id)
      entity = source || source_type.constantize.new
      entity.user_id = user_id if entity.respond_to? :user_id
      entity.public_send "#{attachment_name}=", io: r, filename: media_id

      self.source = entity
      self.save
    end

  end
end
