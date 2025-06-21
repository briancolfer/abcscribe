class CreateJournalEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :journal_entries do |t|
      t.string :antecedent
      t.string :behavior
      t.string :consequence

      t.timestamps
    end
  end
end
