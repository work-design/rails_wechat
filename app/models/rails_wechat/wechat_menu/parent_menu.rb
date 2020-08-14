module RailsWechat::WechatMenu::ParentMenu
  extend ActiveSupport::Concern

  included do
    has_many :children, class_name: self.base_class.name, foreign_key: :parent_id, dependent: :nullify
  end

  def as_json
    {
      name: name,
      sub_button: children.order(position: :asc).as_json
    }
  end

end
