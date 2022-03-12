module Wechat
  module Model::External
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :remark, :string
      attribute :state, :string
      attribute :external_userid, :string
      attribute :gender, :string
      attribute :description, :string

      belongs_to :crm_tag, foreign_key: :state, primary_key: :name
    end

  end
end
