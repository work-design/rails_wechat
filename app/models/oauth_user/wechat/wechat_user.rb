module Wechat
if defined? RailsAuth
  class WechatUser < ::Auth::OauthUser
    include Model::OauthUser::WechatUser
  end
else
  class WechatUser < ApplicationRecord
    include Model::OauthUser::WechatUser
    include OneAi::Ext::Reply if defined? OneAi
  end
end
end
