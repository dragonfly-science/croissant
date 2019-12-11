FactoryBot.define do
  factory :tag do
    name { Faker::Food.vegetables }
  end
end
