class AddMetadataToSubmissions < ActiveRecord::Migration[6.0]
  def change
    change_table :submissions, bulk: true do |t|
      t.datetime :submitted_at
      t.string :channel
      t.string :source
      t.string :name
      t.string :email_address
      t.string :address
      t.string :phone_number
      t.string :query_type
      t.string :anonymise
    end
  end
end
