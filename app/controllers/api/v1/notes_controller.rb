module Api
  module V1
    class NotesController < ApplicationController
      def index
        render json: notes_filtered, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: show_note, status: :ok, serializer: ShowNoteSerializer
      end

      private

      def notes
        Note.all
      end

      def notes_filtered
        notes.where(filtering_params)
             .order(created_at: order_params)
             .page(params[:page])
             .per(params[:page_size])
      end

      def filtering_params
        params.permit(:note_type)
      end

      def order_params
        %w[asc desc].include?(params[:order]) ? params[:order] : :desc
      end

      def show_note
        notes.find(params.require(:id))
      end
    end
  end
end