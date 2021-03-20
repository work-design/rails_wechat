module Wechat
  module Ext::Effective
    extend ActiveSupport::Concern
    include Model::EffectiveModule

    included do
      has_one :wechat_response, class_name: 'Wechat::WechatResponse', as: :effective
    end

  end
end
