# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

u = User.create!(email: 'admin@example.com', password: 'admin123', role: 3)
u.approve
Consultation.create(
  name: 'Consultation one', consultation_type: 0, description: 'First consultation')
Tag.create(taxonomy_id: 1, name: 'fine')
Tag.create(taxonomy_id: 1, name: 'sucks')
Tag.create(taxonomy_id: 1, name: 'fruit')
Submission.create(
  consultation_id: 1,
  text: 'I like the general idea, but section 76C is an outrage. Remove it at once.',
  description: 'Submission one', phone_number: '123'
)
Submission.create(
  consultation_id: 1, text: 'This proposal sucks', description: 'Submission two',
  phone_number: '456', state: 'ready'
)
Submission.create(
  consultation_id: 1, text: "Fine job, should've happened 50 years ago. Let's get on with it.",
  description: 'Submission three', email_address: 'someone@example.com',
  state: 'finished'
)
Submission.create(
  consultation_id: 1,
  text: "potato zucchini mandarin pear orange blah carrot blah peach",
  description: 'Submission three', email_address: 'someone@example.com',
  state: 'finished'
)
SubmissionTag.create(
  tag_id: 2, start_char: 14, end_char: 18, text: 'sucks', tagger_id: 1,
  taggable_type: 'Submission', taggable_id: 2
)
SubmissionTag.create(
  tag_id: 1, start_char: 0, end_char: 3, text: 'Fine', tagger_id: 1,
  taggable_type: 'Submission', taggable_id: 3
)
SubmissionTag.create(
  tag_id: 3, start_char: 16, end_char: 35, text: 'mandarin pear orange', tagger_id: 1,
  taggable_type: 'Submission', taggable_id: 4
)
SubmissionTag.create(
  tag_id: 3, start_char: 54, end_char: 58, text: 'peach', tagger_id: 1,
  taggable_type: 'Submission', taggable_id: 4
)
