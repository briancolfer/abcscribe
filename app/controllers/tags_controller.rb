class TagsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    query = params[:q].to_s.strip
    if query.present?
      @tags = current_user.tags
                         .where("LOWER(name) LIKE ?", "%#{query.downcase}%")
                         .limit(10)
                         .order(:name)
      render json: @tags.select(:id, :name)
    else
      render json: []
    end
  end

  def create
    @tag = current_user.tags.create!(name: params[:name])
    render json: { id: @tag.id, name: @tag.name }
  end
end
