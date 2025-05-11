class CreateSubjects < ActiveRecord::Migration[8.0]
  def change
    create_table :subjects do |t|
      t.string :name, null: false
      t.date :date_of_birth
      t.text :notes
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :subjects, [:user_id, :name], unique: true
  end
end

