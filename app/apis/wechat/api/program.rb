# frozen_string_literal: true

module Wechat::Api
  class Program < Base
    include Base::Sns
    include Program::Wxaapi
    include Program::Wxa

  end
end
