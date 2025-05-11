class CreateObservations < ActiveRecord::Migration[8.0]
  def change
    create_table :observations do |t|
      t.datetime :observed_at, null: false
      t.text :antecedent, null: false
      t.text :behavior, null: false
      t.text :consequence, null: false
      t.text :notes
      t.references :user, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.references :setting, foreign_key: true

      t.timestamps
    end
    
    add_index :observations, :observed_at
  end
end

