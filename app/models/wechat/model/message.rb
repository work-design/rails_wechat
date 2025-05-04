module Wechat
  module Model::Message
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :appid, :string, index: true
      attribute :open_id, :string, index: true
      attribute :msg_id, :string
      attribute :msg_type, :string
      attribute :content, :string
      attribute :encrypt_data, :string
      attribute :message_hash, :json
      attribute :info_type, :string

      belongs_to :platform, optional: true
      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :wechat_user, foreign_key: :open_id, primary_key: :uid, optional: true

      enum :msg_format, {
        json: 'json',
        xml: 'xml'
      }, default: 'xml'
    end

    def app_name
      app.name
    end

  end
end
