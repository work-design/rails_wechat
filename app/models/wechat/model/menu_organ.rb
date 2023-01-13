module Wechat
  module Model::MenuOrgan
    extend ActiveSupport::Concern

    included do
      attribute :appid, :string, index: true
      attribute :name, :string

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :scene, optional: true
      belongs_to :tag, optional: true
      belongs_to :menu
    end

  end
end
