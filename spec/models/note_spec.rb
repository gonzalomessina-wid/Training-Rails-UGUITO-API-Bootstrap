require 'rails_helper'

RSpec.describe Note, type: :model do
  describe 'Associations' do
    it { should belong_to(:user) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:note_type) }
    it { should validate_presence_of(:user_id) }

    describe '#review_max_length' do
      context 'when note_type is review' do
        let(:note) { build(:note, :review, content: content, user: user) }

        context 'with North Utility user' do
          let(:user) { create(:user, utility: create(:north_utility)) }

          context 'when content is within limit (50 words)' do
            let(:content) { 'palabra ' * 50 }
            it { expect(note).to be_valid }
          end

          context 'when content exceeds limit (> 50 words)' do
            let(:content) { 'palabra ' * 51 }
            it 'is invalid and has error message' do
              expect(note).not_to be_valid
              expect(note.errors[:content]).to include(
                "es demasiado largo para una reseña en North Utility (máximo 50 palabras)"
              )
            end
          end
        end

        context 'with South Utility user' do
          let(:user) { create(:user, utility: create(:south_utility)) }

          context 'when content is within limit (60 words)' do
            let(:content) { 'palabra ' * 60 }
            it { expect(note).to be_valid }
          end

          context 'when content exceeds limit (> 60 words)' do
            let(:content) { 'palabra ' * 61 }
            it 'is invalid and has error message' do
              expect(note).not_to be_valid
              expect(note.errors[:content]).to include(
                "es demasiado largo para una reseña en South Utility (máximo 60 palabras)"
              )
            end
          end
        end
      end

      context 'when note_type is not review' do
        let(:user) { create(:user, utility: create(:north_utility)) }
        let(:note) { build(:note, :critique, content: 'palabra ' * 100, user: user) }

        it 'is valid even if it exceeds the review limit' do
          expect(note).to be_valid
        end
      end
    end
  end

  describe '#content_length' do
    let(:user) { create(:user, utility: create(:north_utility)) }
    let(:note) { build(:note, user: user) }

    context 'with North Utility user' do
      it "returns 'short' for up to 50 words" do
        note.content = 'palabra ' * 50
        expect(note.content_length).to eq('short')
      end

      it "returns 'medium' for 51 to 100 words" do
        note.content = 'palabra ' * 51
        expect(note.content_length).to eq('medium')
        note.content = 'palabra ' * 100
        expect(note.content_length).to eq('medium')
      end

      it "returns 'long' for more than 100 words" do
        note.content = 'palabra ' * 101
        expect(note.content_length).to eq('long')
      end
    end

    context 'with South Utility user' do
      let(:user) { create(:user, utility: create(:south_utility)) }

      it "returns 'short' for up to 60 words" do
        note.content = 'palabra ' * 60
        expect(note.content_length).to eq('short')
      end

      it "returns 'medium' for 61 to 120 words" do
        note.content = 'palabra ' * 61
        expect(note.content_length).to eq('medium')
        note.content = 'palabra ' * 120
        expect(note.content_length).to eq('medium')
      end

      it "returns 'long' for more than 120 words" do
        note.content = 'palabra ' * 121
        expect(note.content_length).to eq('long')
      end
    end
  end
end