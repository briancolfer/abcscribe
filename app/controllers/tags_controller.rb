class TagsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @tags = current_user.tags.where("name LIKE ?", "%#{params[:q]}%")
    render json: @tags.select(:id, :name)
  end

  def create
    @tag = current_user.tags.create!(name: params[:name])
    render json: { id: @tag.id, name: @tag.name }
  end
end
