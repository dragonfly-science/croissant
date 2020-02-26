FactoryBot.define do
  factory :submission_tag do
    submission { FactoryBot.create(:submission, :ready_to_tag) }
    tag
    tagger { FactoryBot.create(:user) }
    start_char { Faker::Number.between(from: 1, to: 10) }
    end_char { Faker::Number.between(from: 11, to: 13) }
    text { Faker::Lorem.characters(number: end_char - start_char) }
  end
end
