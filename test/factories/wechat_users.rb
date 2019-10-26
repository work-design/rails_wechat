FactoryBot.define do
  
  factory :wechat_user do
    account_id { 1 }
    provider { 'MyString' }
    type { 'WechatUser' }
    uid { 'MyString' }
    unionid { 'MyString' }
    name { 'MyString' }
    avatar_url { 'MyString' }
    state { 'MyString' }
    access_token { 'MyString' }
    refresh_token { 'MyString' }
    app_id { 'MyString' }
    expires_at { 1.hour.since }
    extra { '' }
  end
  
end
