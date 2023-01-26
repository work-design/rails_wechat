module Wechat
  module Model::Response
    extend ActiveSupport::Concern

    included do
      attribute :match_value, :string
      attribute :contain, :boolean, default: true
      attribute :enabled, :boolean, default: true
      attribute :expire_at, :datetime
      attribute :appid, :string, index: true

      belongs_to :app, foreign_key: :appid, primary_key: :appid
      belongs_to :reply, optional: true
      has_many :extractors, dependent: :delete_all
      has_many :hooks, dependent: :delete_all
      has_many :request_responses, ->(o){ where(appid: o.appid) }, dependent: :destroy_async

      accepts_nested_attributes_for :request_responses, allow_destroy: true

      validates :match_value, presence: true
    end

    def request_types
      request_responses.pluck(:request_type)
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
