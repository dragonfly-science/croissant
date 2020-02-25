FactoryBot.define do
  factory :taxonomy do
    consultation
  end

  trait :with_tags do
    after :create do |taxonomy|
      create_list :tag, 5, taxonomy: taxonomy
    end
  end
end
