module RailsWechat::WechatApp::WechatProgram
  extend ActiveSupport::Concern

  included do

  end

  def api
    return @api if defined? @api
    @api = Wechat::Api::Program.new(self)
  end

  def template_messenger(template)
    Wechat::Message::Template::Program.new(self, template)
  end

end
