module Wechat
  module Model::MenuRootApp
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :appid, :string
      attribute :position, :integer

      belongs_to :menu_root, optional: true
      belongs_to :app, foreign_key: :appid, primary_key: :appid

      has_many :menus, ->(o) { where(o.filter_hash).order(appid: :asc, position: :asc) }, primary_key: :position, foreign_key: :root_position

      acts_as_list scope: [:menu_root_id, :appid]
    end

    def filter_hash
      h = {}
      h.merge! menu_root_id: menu_root_id
      h.merge! appid: appid
      h
    end

    def xx
      @menus = @menu_roots.group_by(&:position).transform_values! do |x|
        x.find(&->(i){ i.organ_id == current_organ.id }) || x.find(&->(i){ i.organ_id.nil? })
      end.values
    end

    def as_json
      {
        name: name,
        sub_button: children.as_json
      }
    end

  end
end
