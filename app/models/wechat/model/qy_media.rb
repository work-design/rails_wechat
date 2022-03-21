module Wechat
  module Model::QyMedia
    extend ActiveSupport::Concern

    included do
      attribute :corp_id, :string
      attribute :suite_id, :string

      belongs_to :corp
    end

  end
end
