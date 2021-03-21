FactoryBot.define do

  factory :app do
    name { 'MyString' }
    type { 'WechatPublic' }
    enabled { true }
    primary { true }
    appid { 'MyString' }
    secret { 'MyString' }
    token { 'MyString' }
    agentid { 'MyString' }
    mch_id { 'MyString' }
    key { 'MyString' }
    encrypt_mode { false }
    encoding_aes_key { 'MyString' }
    access_token { 'MyString' }
    access_token_expires_at { 1.hour.since }
    jsapi_ticket { 'MyString' }
    jsapi_ticket_expires_at { 1.hour.since }
    help { 'MyString' }
    help_without_user { 'MyString' }
    help_feedback { 'MyString' }
  end

end
