FactoryBot.define do
  
  factory :ticket do
    organ_id { 1 }
    match_value { "MyString" }
    serial_start { 1 }
    start_at { Time.current }
    finish_at { 1.week.since }
    valid_response { "MyString" }
    invalid_response { "MyString" }
  end
  
end
