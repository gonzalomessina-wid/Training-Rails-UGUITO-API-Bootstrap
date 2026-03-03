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
        let(:expected) { NoteDetailedSerializer.new(note, root: false).to_json }

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

  describe 'POST #create' do
    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      let(:note_type) { 'review' }
      let(:title)     { Faker::Lorem.sentence }
      let(:content)   { Faker::Lorem.words(number: 5).join(' ') }
      let(:note_params) do
        { note: { title: title, note_type: note_type, content: content } }
      end

      context 'when creating a note with valid params' do
        before { post :create, params: note_params }

        it 'creates a new note' do
          expect(Note.count).to eq(1)
        end

        it 'creates the note with the correct attributes' do
          note = Note.last
          expect(note.title).to eq(title)
          expect(note.note_type).to eq(note_type)
          expect(note.content).to eq(content)
          expect(note.user).to eq(user)
        end

        it 'responds with 201 status' do
          expect(response).to have_http_status(:created)
        end
      end

      context 'when creating a critique note with valid params' do
        let(:note_type) { 'critique' }
        let(:content)   { Faker::Lorem.words(number: 200).join(' ') }

        before { post :create, params: note_params }

        it 'creates a new note' do
          expect(Note.count).to eq(1)
        end

        it 'responds with 201 status' do
          expect(response).to have_http_status(:created)
        end
      end

      context 'when the note param wrapper is missing' do
        before { post :create, params: { title: title, note_type: note_type, content: content } }

        it 'responds with 400 status' do
          expect(response).to have_http_status(:bad_request)
        end
      end

      context 'when title param is missing' do
        before { post :create, params: { note: { note_type: note_type, content: content } } }

        it 'responds with 400 status' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'returns an error message' do
          expect(response_body['errors'].first['message']).to be_present
        end
      end

      context 'when note_type param is missing' do
        before { post :create, params: { note: { title: title, content: content } } }

        it 'responds with 400 status' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'returns an error message' do
          expect(response_body['errors'].first['message']).to be_present
        end
      end

      context 'when content param is missing' do
        before { post :create, params: { note: { title: title, note_type: note_type, content: nil } } }

        it 'does not create a note' do
          expect(Note.count).to eq(0)
        end

        it 'responds with 400 status' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'returns an error message' do
          expect(response_body['errors'].first['message']).to be_present
        end
      end

      context 'when the content of a review note is too long' do
        let(:note_type) { 'review' }
        let(:content)   { Faker::Lorem.words(number: 200).join(' ') }

        before { post :create, params: note_params }

        it 'does not create the note' do
          expect(Note.count).to eq(0)
        end

        it 'responds with 400 status' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'returns an error message' do
          expect(response_body['errors'].first['message']).to be_present
        end
      end
    end

    context 'when there is not a user logged in' do
      context 'when creating a note' do
        before do
          post :create, params: { note: { title: Faker::Lorem.sentence,
                                          note_type: 'review',
                                          content: Faker::Lorem.sentence } }
        end

        it_behaves_like 'unauthorized'
      end
    end
  end
end

