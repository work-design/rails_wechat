FactoryBot.define do
  
  factory :wechat_menu do
    wechat_app
    type { 'ViewMenu' }
    menu_type { 'MyString' }
    name { 'MyString' }
    value { 'MyString' }
    appid { 'MyString' }
    pagepath { 'MyString' }
  end
  
end
