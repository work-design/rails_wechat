module Wechat
  module Model::Supporter
    extend ActiveSupport::Concern

    included do
      attribute :avatar, :string
      attribute :name, :string
      attribute :open_kfid, :string
      attribute :manage_privilege, :boolean
      attribute :corpid, :string, index: true

      belongs_to :corp
    end

    def xx

    end

  end
end
