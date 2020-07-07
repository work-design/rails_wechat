class Wechat::BaseController < ApplicationController
  include RailsAuth::Application

end unless defined? Wechat::BaseController
