module Wechat
  module Model::MenuOrgan
    extend ActiveSupport::Concern

    included do
      attribute :name, :string

      belongs_to :menu
      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :scene, optional: true
      belongs_to :tag, optional: true
    end

  end
end
