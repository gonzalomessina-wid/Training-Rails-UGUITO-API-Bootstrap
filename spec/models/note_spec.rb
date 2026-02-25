require 'rails_helper'

RSpec.describe Note, type: :model do
  describe 'Associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'Validations' do
    describe 'Presence' do
      %i[title content note_type user_id].each do |attribute|
        it { is_expected.to validate_presence_of(attribute) }
      end
    end

    describe '#max_length_of_content_allowed' do
      let(:user) { create(:user, utility: utility) }
      let(:note) { build(:note, :review, content: content, user: user) }
      let(:error_message) { I18n.t('activerecord.errors.models.too_long') }

      context 'when note_type is review' do
        context 'with North Utility user' do
          let(:utility) { create(:north_utility) }

          context 'when content is within limit' do
            let(:content) { Faker::Lorem.sentence(word_count: utility.short_word_count) }

            it { expect(note).to be_valid }
          end

          context 'when content exceeds limit' do
            let(:content) { Faker::Lorem.sentence(word_count: utility.short_word_count + 1) }

            it 'is invalid and has error message' do
              expect(note).not_to be_valid
              expect(note.errors[:content]).to include(error_message)
            end
          end
        end

        context 'with South Utility user' do
          let(:utility) { create(:south_utility) }

          context 'when content is within limit' do
            let(:content) { Faker::Lorem.sentence(word_count: utility.short_word_count) }

            it { expect(note).to be_valid }
          end

          context 'when content exceeds limit' do
            let(:content) { Faker::Lorem.sentence(word_count: utility.short_word_count + 1) }

            it 'is invalid and has error message' do
              expect(note).not_to be_valid
              expect(note.errors[:content]).to include(error_message)
            end
          end
        end
      end

      context 'when note_type is not review' do
        let(:utility) { create(:north_utility) }
        let(:note) { build(:note, :critique, content: Faker::Lorem.sentence(word_count: 100), user: user) }

        it 'is valid even if it exceeds the review limit' do
          expect(note).to be_valid
        end
      end
    end
  end

  describe '#word_count' do
    subject { note.word_count }

    let(:note) { build(:note, content: 'uno dos tres') }

    it { is_expected.to eq(3) }
  end

  describe '#content_length' do
    let(:user) { create(:user, utility: utility) }
    let(:note) { build(:note, user: user) }

    shared_examples 'content length classification' do
      it "returns 'short' for up to short_word_count words" do
        note.content = Faker::Lorem.sentence(word_count: utility.short_word_count)
        expect(note.content_length).to eq('short')
      end

      it "returns 'medium' for boundary of medium length" do
        note.content = Faker::Lorem.sentence(word_count: utility.short_word_count + 1)
        expect(note.content_length).to eq('medium')
      end

      it "returns 'medium' for upper limit of medium length" do
        note.content = Faker::Lorem.sentence(word_count: utility.long_word_count)
        expect(note.content_length).to eq('medium')
      end

      it "returns 'long' for more than long_word_count words" do
        note.content = Faker::Lorem.sentence(word_count: utility.long_word_count + 1)
        expect(note.content_length).to eq('long')
      end
    end

    context 'with North Utility user' do
      let(:utility) { create(:north_utility) }

      include_examples 'content length classification'
    end

    context 'with South Utility user' do
      let(:utility) { create(:south_utility) }

      include_examples 'content length classification'
    end
  end
end

