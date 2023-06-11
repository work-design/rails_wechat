# frozen_string_literal: true

module Wechat
  module Model::PlatformTemplate
    extend ActiveSupport::Concern

    included do
      attribute :user_version, :string
      attribute :template_id, :integer

      enum audit_status: [
        :init,
        :verifying,
        :rejected,
        :approved,
        :commit,
        :commit_fail
      ]

      belongs_to :platform
    end


  end
end
