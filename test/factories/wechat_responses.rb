FactoryBot.define do
  
  factory :wechat_response do
    wechat_app
    effective_type { 'MyString' }
    effective_id { 1 }
    type { 'TextResponse' }
    match_value { 'MyString' }
    qrcode_ticket { 'MyString' }
    qrcode_url { 'MyString' }
    expire_seconds { 1888 }
  end
  
end
