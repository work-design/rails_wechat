module Wechat
  module Model::QyMedia
    extend ActiveSupport::Concern

    included do
      attribute :corpid, :string, index: true
      attribute :suite_id, :string, index: true
      attribute :media_id, :string
      attribute :url, :string
      attribute :medium_attach, :string

      belongs_to :medium, polymorphic: true, optional: true

      belongs_to :corp, ->(o){ where(suite_id: o.suite_id) }, foreign_key: :corpid, primary_key: :corpid
      belongs_to :suite, foreign_key: :suite_id, primary_key: :suite_id
    end

    def upload
      attach = medium.send(medium_attach)
      if attach.attached?
        file = StringIO.new(attache.download)
        corp.api.uploadimg(file)
      end
    end

  end
end
