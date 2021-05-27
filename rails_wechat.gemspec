$:.push File.expand_path('lib', __dir__)
require 'rails_wechat/version'

Gem::Specification.new do |s|
  s.name = 'rails_wechat'
  s.version = RailsWechat::VERSION
  s.authors = ['qinmingyuan']
  s.email = ['mingyuan0715@foxmail.com']
  s.homepage = 'https://github.com/work-design/rails_wechat'
  s.summary = 'Wechat Master'
  s.description = '微信集成一揽子解决方案'
  s.license = 'MIT'

  s.files = Dir[
    '{app,config,db,lib}/**/*',
    'LICENSE',
    'Rakefile',
    'README.md'
  ]

  s.add_dependency 'rails_com', '~> 1.2'
  s.add_dependency 'rails_auth'
  s.add_dependency 'rqrcode'
end
