module Wechat
  module Model::ProviderOrgan
    extend ActiveSupport::Concern

    included do
      attribute :corpid, :string
      attribute :open_corpid, :string

      belongs_to :organ, class_name: 'Org::Organ', foreign_key: :corpid, primary_key: :corpid, inverse_of: :provider_organs
      belongs_to :provider
      has_many :corps, primary_key: :open_corpid, foreign_key: :corp_id, inverse_of: :provider_organs

      after_save_commit :compute_open_corpid, if: -> { saved_change_to_corpid? }
    end

    def compute_open_corpid
      r = provider.api.open_corpid(corpid)
      logger.debug "\e[35m  Corp id: #{r}  \e[0m"
      self.open_corpid = r['open_corpid']
      self.save
    end

  end
end

