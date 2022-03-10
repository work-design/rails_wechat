# frozen_string_literal: true

module Wechat::Api
  class Program < Base
    include Base::Sns
    include Public::Common
    include Wxaapi
    include Wxa
    include CgiBin

  end
end
