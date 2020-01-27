FactoryBot.define do
  factory :consultation do
    name { Faker::Book.title }
    consultation_type { "parliamentary" }
  end

  trait :with_taxonomy_tags do
    taxonomy { create :taxonomy, :with_tags }
  end
end
