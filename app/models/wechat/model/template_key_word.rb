module Wechat
  module Model::TemplateKeyWord
    extend ActiveSupport::Concern

    included do
      attribute :position, :integer
      attribute :kid, :integer
      attribute :name, :string
      attribute :note, :string
      attribute :example, :string
      attribute :rule, :string
      attribute :mapping, :string
      attribute :color, :string

      belongs_to :template_config

      acts_as_list
    end

  end
end
