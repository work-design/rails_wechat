module Wechat
  module Model::MenuRoot
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :position, :integer
      attribute :appid, :string

      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true

      has_many :menus, -> { order(appid: :asc, position: :asc) }, primary_key: :position, foreign_key: :root_position
      has_many :organ_menus, -> { where(appid: nil).order(position: :asc) }, class_name: 'Menu', primary_key: :position, foreign_key: :root_position

      acts_as_list scope: [:organ_id, :appid]
    end

    def as_json
      {
        name: name,
        sub_button: children.as_json
      }
    end

  end
end