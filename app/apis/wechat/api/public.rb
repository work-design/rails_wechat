# frozen_string_literal: true

module Wechat::Api
  class Public < Base
    include Common
    include Material
    include Menu
    include Mp
    include User
    include Wxopen
    include Agency
    include Base::Sns

  end
end
