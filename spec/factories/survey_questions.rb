FactoryBot.define do
  factory :survey_question do
    survey
    question { Faker::Lorem.sentence }
  end
end
