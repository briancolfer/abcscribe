class ObservationsController < ApplicationController
  before_action :authenticate_user
  before_action :set_subject, only: [:index, :new, :create]
  before_action :set_observation, only: [:show, :edit, :update, :destroy]

  def index
    @observations = @subject.observations.includes(:setting)
                          .order(observed_at: :desc)
                          .page(params[:page])
  end

  def show
  end

  def new
    @observation = @subject.observations.build(observed_at: Time.current)
    @settings = current_user.settings.order(:name)
  end

  def create
    @observation = @subject.observations.build(observation_params)
    @observation.user = current_user

    if @observation.save
      redirect_to subject_path(@subject), notice: 'Observation was successfully created.'
    else
      @settings = current_user.settings.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @settings = current_user.settings.order(:name)
  end

  def update
    if @observation.update(observation_params)
      redirect_to observation_path(@observation), notice: 'Observation was successfully updated.'
    else
      @settings = current_user.settings.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    subject = @observation.subject
    @observation.destroy
    redirect_to subject_path(subject), notice: 'Observation was successfully deleted.'
  end

  private

  def set_subject
    @subject = current_user.subjects.find(params[:subject_id])
  end

  def set_observation
    @observation = current_user.observations.includes(:subject, :setting).find(params[:id])
  end

  def observation_params
    params.require(:observation).permit(:observed_at, :antecedent, :behavior, 
                                      :consequence, :notes, :setting_id)
  end
end

