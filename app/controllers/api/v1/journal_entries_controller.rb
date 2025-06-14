module Api
  module V1
    class JournalEntriesController < BaseController
      before_action :set_journal_entry, only: [:show, :update, :destroy]

      def index
        @journal_entries = current_user.journal_entries
        render json: @journal_entries
      end

      def show
        render json: @journal_entry
      end

      def create
        @journal_entry = current_user.journal_entries.build(journal_entry_params)

        if @journal_entry.save
          render json: @journal_entry, status: :created
        else
          render json: { errors: @journal_entry.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @journal_entry.update(journal_entry_params)
          render json: @journal_entry
        else
          render json: { errors: @journal_entry.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @journal_entry.destroy
        head :no_content
      end

      private

      def set_journal_entry
        @journal_entry = current_user.journal_entries.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_not_found("Journal entry not found")
      end

      def journal_entry_params
        params.require(:journal_entry).permit(:occurred_at, :antecedent, :behavior, :consequence, :reinforcement_type)
      end
    end
  end
end

