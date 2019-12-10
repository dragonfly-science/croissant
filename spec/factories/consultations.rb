FactoryBot.define do
  factory :consultation do
    name { Faker::Book.title }
    consultation_type { "parliamentary" }
  end
end
