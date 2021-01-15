module Wechat
  module Model::Effective
    extend ActiveSupport::Concern

    include Model::EffectiveModule
    included do
      has_one :wechat_response, as: :effective
    end

  end
end
