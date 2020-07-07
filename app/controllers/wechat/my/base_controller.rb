class Wechat::My::BaseController < MyController
  include RailsWechat::Application

end unless defined? Wechat::My::BaseController
