module Wechat
  module Model::Contact
    extend ActiveSupport::Concern

    included do
      attribute :corp_id, :string
      attribute :user_id, :string
      attribute :part_id, :string
      attribute :config_id, :string
      attribute :qr_code, :string
      attribute :remark, :string
      attribute :skip_verify, :boolean, default: true
    end

  end
end

