module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!
      before_action :validate_type_param, only: [:index]
      before_action :validate_order_param, only: [:index]
      before_action :set_note, only: [:show]

      def index
        render json: response_notes_index, status: :ok, each_serializer: NoteIndexSerializer
      end

      def show
        render json: set_note, status: :ok, serializer: NoteDetailedSerializer
      end

      def create
        create_method
      end

      def index_async
        response = execute_async(RetrieveNotesWorker, current_user.id, index_async_params)
        async_custom_response(response)
      end

      private

      def create_method
        render json: { message: I18n.t('controller.create.success') }, status: :created if Note.create!(note_create_params)
      rescue ActiveRecord::RecordInvalid => e
        raise Exceptions::InvalidParameterError, e.record.errors.full_messages.join(', ')
      end

      def note_create_params

        params.require(:note)
              .permit(:title, :note_type, :content)
              .merge(user: current_user)
      end

      def set_note
        Note.find(params[:id])
      end

      def notes_filtered
        Note.where(params.permit(:note_type))
      end

      def order_notes
        notes_filtered.order(created_at: params[:order] || :desc)
      end

      def response_notes_index
        order_notes.page(params[:page]).per(params[:page_size])
      end

      def validate_type_param
        if params[:note_type] && !Note.note_types.keys.include?(params[:note_type])
          render json: { error: I18n.t('activerecord.errors.controller.note.note_type_param') }, status: :bad_request
        end
      end

      def validate_order_param
        allowed_types = %w[asc desc]
        if params[:order] && !allowed_types.include?(params[:order])
          render json: { error: I18n.t('activerecord.errors.controller.note.order_params') }, status: :bad_request
        end
      end

      def index_async_params
        { author: params.require(:author) }
      end
    end
  end
end
