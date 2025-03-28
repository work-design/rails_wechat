# frozen_string_literal: true

module Wechat
  class PublicApi < BaseApi
    include BaseApi::Sns
    include Agency
    include Common
    include Material
    include Menu
    include Mp
    include User
    include Wxopen

  end
end
