require 'rails_helper'

RSpec.describe Guess, type: :model do
  let(:guess) { Guess.new(letter: 'A') }

  context "#valid?" do
    it "is valid when all fields are valid" do
      expect(guess.valid?).to be_truthy
    end

    it "is invalid when letter is too long" do
      guess.letter = 'ab'
      expect(guess.valid?).to be_falsey
    end
  end
end
