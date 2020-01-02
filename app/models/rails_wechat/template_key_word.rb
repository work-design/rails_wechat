module RailsWechat::TemplateKeyWord
  extend ActiveSupport::Concern

  included do
    attribute :position, :integer
    attribute :kid, :integer
    attribute :name, :string
    attribute :example, :string
    attribute :rule, :string
    attribute :mapping, :string

    belongs_to :public_template

    acts_as_list
  end

end
