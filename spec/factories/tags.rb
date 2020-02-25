FactoryBot.define do
  factory :tag do
    name { "#{Faker::Food.vegetables} #{Faker::Food.fruits} #{Faker::Food.ingredient}" }
    taxonomy
  end
end
