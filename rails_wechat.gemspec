$:.push File.expand_path('lib', __dir__)
require 'rails_wechat/version'

Gem::Specification.new do |s|
  s.name = 'rails_wechat'
  s.version = RailsWechat::VERSION
  s.authors = ['qinmingyuan']
  s.email = ['mingyuan0715@foxmail.com']
  s.homepage = 'https://github.com/work-design/rails_wechat'
  s.summary = 'Summary of RailsWechat.'
  s.description = 'Description of RailsWechat.'
  s.license = 'LGPL-3.0'

  s.files = Dir[
    '{app,config,db,lib}/**/*',
    'LICENSE',
    'Rakefile',
    'README.md'
  ]

  s.add_dependency 'rails', '~> 6.0.0.rc1'
  s.add_dependency 'http', '~> 4.1'
  s.add_dependency 'rails_auth'
  s.add_development_dependency 'sqlite3'
end
