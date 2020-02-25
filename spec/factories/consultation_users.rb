FactoryBot.define do
  factory :consultation_user do
    user { FactoryBot.create(:user) }
    consultation { FactoryBot.create(:consultation) }
    role { "viewer" }
  end
end
