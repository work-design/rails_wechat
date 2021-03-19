module Wechat
  module Model::WechatResponse
    extend ActiveSupport::Concern

    included do
      delegate :url_helpers, to: 'Rails.application.routes'

      attribute :request_types, :string, array: true
      attribute :match_value, :string
      attribute :contain, :boolean, default: true
      attribute :enabled, :boolean, default: true
      attribute :expire_at, :datetime
      attribute :appid, :string, index: true

      belongs_to :wechat_app, foreign_key: :appid, primary_key: :appid
      belongs_to :effective, polymorphic: true, optional: true
      has_many :wechat_extractors, dependent: :delete_all
      has_many :wechat_response_requests, dependent: :delete_all
      accepts_nested_attributes_for :wechat_response_requests, allow_destroy: true

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
      types = wechat_response_requests.pluck(:request_type)
      adds = request_types - types
      removes = types - request_types
      adds.each do |add|
        self.wechat_response_requests.create(request_type: add) unless add.blank?
      end
      self.wechat_response_requests.where(request_type: removes).delete_all
    end

    def invoke_effect(request)
      r = do_extract(request)
      if effective
        request.wechat_reply = effective.invoke_effect(request, value: r.join(','))
      end
    end

    def do_extract(request)
      wechat_extractors.map do |wechat_extractor|
        matched = request.body.scan(wechat_extractor.scan_regexp)
        if matched.blank?
          next
        else
          logger.debug "=====> Matched: #{matched.inspect}, Extractor: #{wechat_extractor.name}/#{wechat_extractor.id}"
        end

        ex = request.wechat_extractions.find_or_initialize_by(wechat_extractor_id: wechat_extractor.id)
        ex.name = wechat_extractor.name
        ex.matched = matched.join(', ')
        if wechat_extractor.serial && wechat_extractor.effective?(request.created_at)
          ex.serial_number ||= wechat_extractor.serial_number
          r = ex.respond_text
        else
          r = wechat_extractor.invalid_response.presence
        end
        ex.save

        r
      end.compact
    end

  end
end
