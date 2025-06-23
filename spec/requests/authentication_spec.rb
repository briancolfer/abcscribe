require 'rails_helper'

RSpec.describe "Authentication", type: :request do
  let(:user) { create(:user) }
  
  describe "accessing protected resources without authentication" do
    context "when accessing journal entries index" do
      it "redirects to the sign-in page" do
        get "/journal_entries"
        
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    context "when accessing journal entries show" do
      let(:journal_entry) { create(:journal_entry, user: user) }
      
      it "redirects to the sign-in page" do
        get "/journal_entries/#{journal_entry.id}"
        
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    context "when accessing journal entries new" do
      it "redirects to the sign-in page" do
        get "/journal_entries/new"
        
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    context "when accessing journal entries edit" do
      let(:journal_entry) { create(:journal_entry, user: user) }
      
      it "redirects to the sign-in page" do
        get "/journal_entries/#{journal_entry.id}/edit"
        
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    context "when trying to create a journal entry" do
      it "redirects to the sign-in page" do
        post "/journal_entries", params: {
          journal_entry: {
            antecedent: "Test antecedent",
            behavior: "Test behavior",
            consequence: "Test consequence"
          }
        }
        
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    context "when trying to update a journal entry" do
      let(:journal_entry) { create(:journal_entry, user: user) }
      
      it "redirects to the sign-in page" do
        patch "/journal_entries/#{journal_entry.id}", params: {
          journal_entry: { antecedent: "Updated antecedent" }
        }
        
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    context "when trying to delete a journal entry" do
      let(:journal_entry) { create(:journal_entry, user: user) }
      
      it "redirects to the sign-in page" do
        delete "/journal_entries/#{journal_entry.id}"
        
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
  
  describe "accessing protected resources with authentication" do
    before do
      sign_in user
    end
    
    context "when accessing journal entries index" do
      it "allows access" do
        get "/journal_entries"
        
        expect(response).to have_http_status(:success)
      end
    end
    
    context "when accessing journal entries show" do
      let(:journal_entry) { create(:journal_entry, user: user) }
      
      it "allows access" do
        get "/journal_entries/#{journal_entry.id}"
        
        expect(response).to have_http_status(:success)
      end
    end
    
    context "when accessing journal entries new" do
      it "allows access" do
        get "/journal_entries/new"
        
        expect(response).to have_http_status(:success)
      end
    end
    
    context "when accessing journal entries edit" do
      let(:journal_entry) { create(:journal_entry, user: user) }
      
      it "allows access" do
        get "/journal_entries/#{journal_entry.id}/edit"
        
        expect(response).to have_http_status(:success)
      end
    end
    
    context "when creating a journal entry" do
      it "allows access and creates the entry" do
        expect {
          post "/journal_entries", params: {
            journal_entry: {
              antecedent: "Test antecedent",
              behavior: "Test behavior",
              consequence: "Test consequence"
            }
          }
        }.to change(JournalEntry, :count).by(1)
        
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(journal_entry_path(JournalEntry.last))
      end
    end
    
    context "when updating a journal entry" do
      let(:journal_entry) { create(:journal_entry, user: user) }
      
      it "allows access and updates the entry" do
        patch "/journal_entries/#{journal_entry.id}", params: {
          journal_entry: { antecedent: "Updated antecedent" }
        }
        
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(journal_entry_path(journal_entry))
        
        journal_entry.reload
        expect(journal_entry.antecedent).to eq("Updated antecedent")
      end
    end
    
    context "when deleting a journal entry" do
      let!(:journal_entry) { create(:journal_entry, user: user) }
      
      it "allows access and deletes the entry" do
        expect {
          delete "/journal_entries/#{journal_entry.id}"
        }.to change(JournalEntry, :count).by(-1)
        
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(journal_entries_path)
      end
    end
  end
  
  describe "session management" do
    context "when signing in programmatically" do
      it "establishes a valid session" do
        sign_in user
        
        get "/journal_entries"
        expect(response).to have_http_status(:success)
        
        # Verify session is active by checking controller's current_user
        expect(controller.send(:current_user)).to eq(user)
      end
    end
    
    context "when signing out" do
      before do
        sign_in user
      end
      
      it "invalidates the session" do
        # Verify user is signed in
        get "/journal_entries"
        expect(response).to have_http_status(:success)
        
        # Sign out
        sign_out user
        
        # Verify session is invalidated - protected resource should redirect
        get "/journal_entries"
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    context "when making requests after sign-out" do
      before do
        sign_in user
        sign_out user
      end
      
      it "prevents access to all protected resources" do
        # Test multiple endpoints to ensure session is fully invalidated
        protected_endpoints = [
          { method: :get, path: "/journal_entries" },
          { method: :get, path: "/journal_entries/new" },
          { method: :post, path: "/journal_entries", params: { journal_entry: { antecedent: "test" } } }
        ]
        
        protected_endpoints.each do |endpoint|
          case endpoint[:method]
          when :get
            get endpoint[:path]
          when :post
            post endpoint[:path], params: endpoint[:params] || {}
          end
          
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end
  
end
