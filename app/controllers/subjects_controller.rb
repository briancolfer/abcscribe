class SubjectsController < ApplicationController
  before_action :authenticate_user
  before_action :set_subject, only: [:show, :edit, :update, :destroy]

  def index
    @subjects = current_user.subjects.order(name: :asc)
  end

  def show
    @recent_observations = @subject.observations.includes(:setting)
                                  .order(observed_at: :desc)
                                  .limit(5)
  end

  def new
    @subject = current_user.subjects.build
  end

  def create
    @subject = current_user.subjects.build(subject_params)
    
    if @subject.save
      redirect_to @subject, notice: 'Subject was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @subject.update(subject_params)
      redirect_to @subject, notice: 'Subject was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @subject.destroy
    redirect_to subjects_path, notice: 'Subject was successfully deleted.'
  end

  private

  def set_subject
    @subject = current_user.subjects.find(params[:id])
  end

  def subject_params
    params.require(:subject).permit(:name, :date_of_birth, :notes)
  end
end
