module Wechat
  module Model::Supporter
    extend ActiveSupport::Concern

    included do
      attribute :avatar, :string
      attribute :name, :string
      attribute :open_kfid, :string
      attribute :manage_privilege, :boolean

      belongs_to :agent
    end

    def xx

    end

  end
end
