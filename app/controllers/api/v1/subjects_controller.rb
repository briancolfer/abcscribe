module Api
  module V1
    class SubjectsController < BaseController
      before_action :set_subject, only: [:show, :update, :destroy]

      # GET /api/v1/subjects
      def index
        base_query = current_user.subjects
        
        @filtered_subjects = apply_filters(base_query)
        total_count = base_query.count

        options = {
          meta: {
            total_count: total_count,
            filtered_count: @filtered_subjects.try(:length) || @filtered_subjects.count
          }
        }

        render json: Api::V1::SubjectSerializer.new(@filtered_subjects, options).serializable_hash
      end

      # GET /api/v1/subjects/:id
      def show
        render json: Api::V1::SubjectSerializer.new(@subject, 
          include: [:observations],
          fields: {
            subject: [:name, :date_of_birth, :notes, :age, :observations_count],
            observation: [:observed_at, :antecedent, :behavior, :consequence, :setting_name]
          }
        ).serializable_hash
      end

      # POST /api/v1/subjects
      def create
        @subject = current_user.subjects.build(subject_params)

        if @subject.save
          render json: Api::V1::SubjectSerializer.new(@subject).serializable_hash,
                 status: :created
        else
          render_error_response(@subject.errors)
        end
      end

      # PATCH/PUT /api/v1/subjects/:id
      def update
        if @subject.update(subject_params)
          render json: Api::V1::SubjectSerializer.new(@subject).serializable_hash
        else
          render_error_response(@subject.errors)
        end
      end

      # DELETE /api/v1/subjects/:id
      def destroy
        if @subject.user_id == current_user.id
          if @subject.destroy
            head :no_content
          else
            render_error_response(@subject.errors)
          end
        else
          render_not_found
        end
      end

      private

      def apply_filters(query)
        query = query.search_by_name(search_params[:query])
        query = query.with_dob_between(parse_date(:start_date), parse_date(:end_date))
        query = query.with_observation_count(search_params[:min_observations])
        
        # If no sort parameters are specified, default to sorting by name
        if search_params[:sort_by].present?
          query.order_by_field(search_params[:sort_by], search_params[:sort_direction])
        else
          query.order_by_field(:name, :asc)
        end
      end

      def set_subject
        @subject = Subject.find_by(id: params[:id])
        
        if @subject.nil? || @subject.user_id != current_user.id
          render_not_found
        end
      end

      def subject_params
        params.require(:subject).permit(:name, :date_of_birth, :notes)
      end
      
      def search_params
        @search_params ||= params.permit(
          :query, :start_date, :end_date, :min_observations, 
          :sort_by, :sort_direction
        )
      end

      def parse_date(param_key)
        Date.parse(params[param_key]) if params[param_key].present?
      rescue Date::Error
        nil
      end

      def render_error_response(errors)
        super(errors.to_hash) # Use the base controller's error formatter
      end
    end
  end
end

