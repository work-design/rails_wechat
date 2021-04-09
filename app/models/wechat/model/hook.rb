module Wechat
  module Model::Hook
    extend ActiveSupport::Concern

    included do

      belongs_to :response
      belongs_to :hooked, polymorphic: true
    end


  end
end
