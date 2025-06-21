class CreateJournalEntryTags < ActiveRecord::Migration[8.0]
  def change
    create_table :journal_entry_tags do |t|
      t.references :journal_entry, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :journal_entry_tags, [:journal_entry_id, :tag_id], unique: true
  end
end
