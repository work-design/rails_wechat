# frozen_string_literal: true

module Wechat
  module Model::PlatformTemplate
    extend ActiveSupport::Concern

    included do
      attribute :user_version, :string
      attribute :template_id, :integer

      enum audit_status: {
        init: 0,
        verifying: 1,
        rejected: 2,
        approved: 3,
        commit: 4,
        commit_fail: 5
      }


      belongs_to :platform
    end


  end
end
