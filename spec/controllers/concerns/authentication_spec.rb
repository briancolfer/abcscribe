require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    include Authentication
    
    before_action :authenticate_user, only: [:protected_action]
    
    def protected_action
      render plain: 'OK'
    end
    
    def public_action
      render plain: 'OK'
    end
  end

  before do
    routes.draw do
      get 'protected_action' => 'anonymous#protected_action'
      get 'public_action' => 'anonymous#public_action'
      get 'login' => 'sessions#new', as: :login
    end
  end

  let(:user) { create(:user) }

  describe '#authenticate_user' do
    context 'when user is logged in' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
        allow(controller).to receive(:logged_in?).and_return(true)
      end

      it 'allows access to the action' do
        get :protected_action
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login page' do
        get :protected_action
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("Please log in to access this page")
      end
    end
  end

  describe '#current_user' do
    it 'returns the logged in user from session' do
      allow(User).to receive(:find_by).with(id: user.id).and_return(user)
      @request.session[:user_id] = user.id
      expect(controller.send(:current_user)).to eq(user)
    end

    it 'returns nil when no user is logged in' do
      expect(controller.send(:current_user)).to be_nil
    end

    it 'returns user from remember token if session is empty' do
      # First, create a real remember token
      user.remember
      
      # Setup the token in cookies
      @request.cookies[:remember_token] = user.remember_token

      # Mock the user lookup and remembered? check
      allow(User).to receive(:find_by).with(remember_token: user.remember_token).and_return(user)
      allow(user).to receive(:remembered?).and_return(true)

      # Test the current_user method
      result = controller.send(:current_user)
      expect(result).to eq(user)
      expect(@request.session[:user_id]).to eq(user.id)
    end
  end

  describe '#logged_in?' do
    it 'returns true when user is logged in' do
      allow(controller).to receive(:current_user).and_return(user)
      expect(controller.send(:logged_in?)).to be_truthy
    end

    it 'returns false when no user is logged in' do
      allow(controller).to receive(:current_user).and_return(nil)
      expect(controller.send(:logged_in?)).to be_falsey
    end
  end
end

