# frozen_string_literal: true

class Wechat::Api::Work < Wechat::Api::Base
  require 'wechat/api/work/agent'
  require 'wechat/api/work/menu'
  require 'wechat/api/work/user'

  include Agent
  include Menu
  include User

  def initialize(app)
    super
    @agentid = app.agentid
  end

end
