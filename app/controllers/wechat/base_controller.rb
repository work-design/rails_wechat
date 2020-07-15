class Wechat::BaseController < BaseController
  include RailsAuth::Application

end unless defined? Wechat::BaseController
