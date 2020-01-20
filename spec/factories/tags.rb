FactoryBot.define do
  factory :tag do
    name { "#{Faker::Food.vegetables} #{Faker::Food.fruits}" }
    taxonomy
  end
end
