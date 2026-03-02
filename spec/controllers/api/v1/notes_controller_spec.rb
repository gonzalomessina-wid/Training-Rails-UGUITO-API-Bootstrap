require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      let(:user_notes) { create_list(:note, 5, user: user) }

      context 'when fetching all the notes' do
        let(:notes_expected) { user_notes.reverse }
        let!(:expected) do
          ActiveModel::Serializer::CollectionSerializer.new(notes_expected,
                                                            serializer: NoteIndexSerializer).to_json
        end

        before { get :index }

        it 'responds with the expected notes json' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching notes with page and page size params' do
        let(:page)           { 1 }
        let(:page_size)      { 2 }

        let(:notes_expected) { user_notes.reverse.first(2) }
        let!(:expected) do
          ActiveModel::Serializer::CollectionSerializer.new(notes_expected,
                                                            serializer: NoteIndexSerializer).to_json
        end

        before { get :index, params: { page: page, page_size: page_size } }

        it 'responds with the expected notes' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching notes using note_type filter' do
        let!(:critique_notes) { create_list(:note, 2, user: user, note_type: :critique) }

        let(:notes_expected)  { critique_notes.reverse }
        let!(:expected) do
          ActiveModel::Serializer::CollectionSerializer.new(notes_expected,
                                                            serializer: NoteIndexSerializer).to_json
        end

        before { get :index, params: { note_type: 'critique' } }

        it 'responds with the expected notes' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching notes ordered ascending' do
        let(:notes_expected) { user_notes }
        let!(:expected) do
          ActiveModel::Serializer::CollectionSerializer.new(notes_expected,
                                                            serializer: NoteIndexSerializer).to_json
        end

        before { get :index, params: { order: 'asc' } }

        it 'responds with the expected notes in ascending order' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching notes with an invalid note_type filter' do
        before { get :index, params: { note_type: 'invalid_type' } }

        it 'responds with 400 status' do
          expect(response).to have_http_status(:bad_request)
        end
      end

      context 'when fetching notes with an invalid order param' do
        before { get :index, params: { order: 'invalid_order' } }

        it 'responds with 400 status' do
          expect(response).to have_http_status(:bad_request)
        end
      end
    end

    context 'when there is not a user logged in' do
      context 'when fetching all the notes' do
        before { get :index }

        it_behaves_like 'unauthorized'
      end
    end
  end

  describe 'GET #show' do
    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      context 'when fetching a valid note' do
        let(:note)     { create(:note, user: user) }
        let(:expected) { NoteShowSerializer.new(note, root: false).to_json }

        before { get :show, params: { id: note.id } }

        it 'responds with the note json' do
          expect(response.body).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching an invalid note' do
        before { get :show, params: { id: Faker::Number.number } }

        it 'responds with 404 status' do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when there is not a user logged in' do
      context 'when fetching a note' do
        before { get :show, params: { id: Faker::Number.number } }

        it_behaves_like 'unauthorized'
      end
    end
  end
end
