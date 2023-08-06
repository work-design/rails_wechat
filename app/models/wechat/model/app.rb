module Wechat
  module Model::App
    extend ActiveSupport::Concern
    include Inner::Token
    include Inner::JsToken
    include Inner::App

  end
end
