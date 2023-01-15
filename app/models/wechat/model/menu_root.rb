module Wechat
  module Model::MenuRoot
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :position, :integer

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      has_many :menus, ->(o) { where(organ_id: [o.organ_id, nil]).order(position: :asc) }, dependent: :nullify

      acts_as_list scope: [:organ_id]
    end

    def as_json
      {
        name: name,
        sub_button: children.as_json
      }
    end

  end
end
