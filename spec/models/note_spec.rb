require 'rails_helper'

RSpec.describe Note, type: :model do
  # Escenario para North Utility
  context "when belongs to North Utility" do
    let(:utility) { Utility.create!(name: "North Utility", type: "NorthUtility") }
    let(:user)    { User.create!(utility: utility, email: "test@north.com", password: "password") }

    it "return 'short' if content has less than 50 words" do
      note = Note.new(content: "palabra " * 50, user: user)
      expect(note.content_length).to eq("short")
    end

    it "return 'medium' if content has between 50 and 101 words" do
      note = Note.new(content: "palabra " * 51, user: user)
      expect(note.content_length).to eq("medium")
    end

    it "return 'long' if content has more than 101 words" do
      note = Note.new(content: "palabra " * 101, user: user)
      expect(note.content_length).to eq("long")
    end

    it "return invalido if content has more than 50 words and content is typo review" do
      note = Note.new(content: "palabra " * 101, user: user)
      expect(note.content_length).to eq("long")
    end
  end
end