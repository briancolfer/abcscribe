class AddAntecedentAndBehaviorToJournalEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :journal_entries, :antecedent, :text
    add_column :journal_entries, :behavior, :text
    
    # Remove the foreign key constraint and behavior_id column
    remove_foreign_key :journal_entries, :behaviors
    remove_column :journal_entries, :behavior_id, :integer
  end
end
