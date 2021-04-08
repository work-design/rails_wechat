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
      after_save_commit :sync_to_response_requests, if: -> { saved_change_to_request_types? }
    end

    def scan_regexp(body)
      if contain
        body.match? Regexp.new(match_value)
      else
        !body.match?(Regexp.new match_value)
      end
    end

    def sync_to_response_requests
      types = response_requests.pluck(:request_type)
      adds = request_types - types
      removes = types - request_types
      adds.each do |add|
        self.response_requests.create(request_type: add) unless add.blank?
      end
      self.response_requests.where(request_type: removes).delete_all
    end

    def invoke_effect(request)
      r = extractors.map do |extractor|
        extractor.invoke_effect(request)
      end.compact

      if reply
        reply.invoke_effect(request, value: r.join(','))
      end
    end

  end
end
