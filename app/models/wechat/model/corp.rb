module Wechat
  module Model::Corp
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :corp_id, :string, index: true

      belongs_to :organ, class_name: 'Org::Organ'
    end


  end
end
