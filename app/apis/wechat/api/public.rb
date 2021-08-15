# frozen_string_literal: true

module Wechat::Api
  class Public < Base
    include Base
    include Material
    include Menu
    include Mp
    include User

  end
end
