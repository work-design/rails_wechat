module Wechat
  module Model::Response
    extend ActiveSupport::Concern

    included do
      delegate :url_helpers, to: 'Rails.application.routes'

      attribute :request_types, :string, array: true
      attribute :match_value, :string
      attribute :contain, :boolean, default: true
      attribute :enabled, :boolean, default: true
      attribute :expire_at, :datetime
      attribute :appid, :string, index: true

      belongs_to :app, foreign_key: :appid, primary_key: :appid
      belongs_to :reply, optional: true
      belongs_to :effective, polymorphic: true, optional: true
      has_many :extractors, dependent: :delete_all
      has_many :response_requests, dependent: :delete_all
      accepts_nested_attributes_for :response_requests, allow_destroy: true

      validates :match_value, presence: true

      before_validation do
        self.match_value ||= "#{effective_type}_#{effective_id}"
      end
    end

    def scan_regexp(body)
      if contain
        body.match? Regexp.new(match_value)
      else
        !body.match?(Regexp.new match_value)
      end
    end

    def invoke_effect(request)
      r = extractors.map(&->(extractor){ extractor.invoke_effect(request) }).compact

      if reply
        reply.invoke_effect(request, value: r.join(','))
      end
    end

  end
end
