module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!
      before_action :validate_type_param, only: [:index]
      before_action :validate_order_param, only: [:index]

      def index
        render json: response_notes_index, status: :ok, each_serializer: NoteIndexSerializer
      end

      def show
        render json: Note.find(show_params[:id]), status: :ok, serializer: NoteShowSerializer
      end

      private
      def show_params
        params.require(:id)
        params.permit(:id)
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
        allowed_types = %w[review critique]
        if params[:note_type] && !allowed_types.include?(params[:note_type].to_s)
          render_error(I18n.t('activerecord.errors.controller.note.note_type_param'))
        end
      end

      def validate_order_param
        allowed_types = %w[asc desc]
        if params[:order] && !allowed_types.include?(params[:order].to_s)
          render_error(I18n.t('activerecord.errors.controller.note.order_params'))
        end
      end

      def render_error(message)
        render json: { error: message }, status: :bad_request
      end

    end
  end
