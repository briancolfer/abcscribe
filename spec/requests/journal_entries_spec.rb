# spec/requests/journal_entries_spec.rb
require 'rails_helper'

RSpec.describe "JournalEntries", type: :request do
  let(:user) { create(:user) }
  let!(:existing_tag) { create(:tag, user: user, name: "ExistingTag") }

  before { login_as(user, scope: :user) }

  describe "POST /journal_entries" do
    it "assigns existing tags to the journal entry" do
      post "/journal_entries", params: {
        journal_entry: {
          antecedent: "An antecedent",
          behavior: "A behavior",
          consequence: "A consequence",
          tag_ids: [existing_tag.id]
        }
      }
      expect(JournalEntry.count).to eq(1)
      expect(JournalEntry.last.tags).to include(existing_tag)
    end

    it "creates and assigns new tags to the journal entry" do
      post "/journal_entries", params: {
        journal_entry: {
          antecedent: "An antecedent",
          behavior: "A behavior",
          consequence: "A consequence",
          new_tags: ["NewTag"]
        }
      }
      expect(JournalEntry.last.tags.pluck(:name)).to include("NewTag")
    end

    it "assigns both existing and new tags" do
      post "/journal_entries", params: {
        journal_entry: {
          antecedent: "An antecedent",
          behavior: "A behavior",
          consequence: "A consequence",
          tag_ids: [existing_tag.id],
          new_tags: ["AnotherTag"]
        }
      }
      tag_names = JournalEntry.last.tags.pluck(:name)
      expect(tag_names).to include("ExistingTag", "AnotherTag")
    end
  end
  # spec/requests/journal_entries_spec.rb
  describe "PATCH /journal_entries/:id" do
    let!(:journal_entry) { create(:journal_entry, user: user) }

    it "assigns existing tags on update" do
      patch "/journal_entries/#{journal_entry.id}", params: {
        journal_entry: { tag_ids: [existing_tag.id] }
      }
      expect(journal_entry.reload.tags).to include(existing_tag)
    end

    it "creates and assigns new tags on update" do
      patch "/journal_entries/#{journal_entry.id}", params: {
        journal_entry: { new_tags: ["UpdatedTag"] }
      }
      expect(journal_entry.reload.tags.pluck(:name)).to include("UpdatedTag")
    end
  end
end