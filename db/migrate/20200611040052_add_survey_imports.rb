class AddSurveyImports < ActiveRecord::Migration[6.0]
  def change
    create_table :survey_imports do |t|
      t.references :consultation, null: false, foreign_key: true
      t.timestamps
    end
  end
end
