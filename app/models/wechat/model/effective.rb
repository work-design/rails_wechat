module Wechat
  module RailsWechat::Effective
    extend ActiveSupport::Concern

    include RailsWechat::EffectiveModule
    included do
      has_one :wechat_response, as: :effective
    end

  end
end
