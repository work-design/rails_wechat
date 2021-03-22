FactoryBot.define do

  factory :menu do
    app
    type { 'ViewMenu' }
    menu_type { 'MyString' }
    name { 'MyString' }
    value { 'MyString' }
    appid { 'MyString' }
    pagepath { 'MyString' }
  end

end
