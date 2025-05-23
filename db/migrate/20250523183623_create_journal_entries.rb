class CreateJournalEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :journal_entries do |t|
      t.datetime :occurred_at
      t.text :consequence
      t.integer :reinforcement_type
      t.references :user, null: false, foreign_key: true
      t.references :behavior, null: false, foreign_key: true

      t.timestamps
    end
  end
end
