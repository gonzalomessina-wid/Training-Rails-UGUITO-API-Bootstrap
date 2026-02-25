module Api
  module V1
    class NotesController < ApplicationController

      def index
        notes = Note.all
        notes = notes.where(content: params[:filter]) if params[:filter].present?
        notes = notes.order(params[:order]) if params[:order].present?
        render json: notes, status: :ok
      end

      def show
        render json: Note.find(params[:id]), status: :ok
      end

    end
  end
end