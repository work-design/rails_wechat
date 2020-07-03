# frozen_string_literal: true
module Wechat::Message; end
require 'wechat/message/base'

require 'wechat/message/mass'
require 'wechat/message/mass/public'
require 'wechat/message/mass/work'

require 'wechat/message/template'
require 'wechat/message/template/public'
require 'wechat/message/template/program'

require 'wechat/message/received'

require 'wechat/message/replied'
require 'wechat/message/custom'  # 客服消息
require 'wechat/message/replied/work'
