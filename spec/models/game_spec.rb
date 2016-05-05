require 'rails_helper'

RSpec.describe Game, type: :model do
  let(:game) { Game.new(word: 'ruby', lives: 4) }

  context "#initialize" do
    it "initial game is not over" do
      expect(game.over?).to be_falsey
      expect(game.won?).to be_falsey
      expect(game.lost?).to be_falsey

      expect(game.lives_left).to eq 4

      expect(game.solved_char_status).to eq [ false, false, false, false ]
    end

  end

  context "playing game" do
    before do
      game.save!

      guesses.each {|g| game.guesses.create!({ letter: g }) }
    end

    context "after one incorrect guess" do
      let(:guesses) { ['A'] }

      it "has correct state " do

        expect(game.over?).to be_falsey
        expect(game.won?).to be_falsey
        expect(game.lost?).to be_falsey

        expect(game.lives_left).to eq 3

        expect(game.solved_char_status).to eq [ false, false, false, false ]
      end
    end

    context "after one correct guess" do
      let(:guesses) { ['R'] }

      it "has correct state" do
        expect(game.over?).to be_falsey
        expect(game.won?).to be_falsey
        expect(game.lost?).to be_falsey

        expect(game.lives_left).to eq 4

        expect(game.solved_char_status).to eq [ true, false, false, false ]
      end
    end

    context "after 4 wrong guesses" do
      let(:guesses) { ['X', 'E', 'Q', 'W'] }

      it "is over" do

        expect(game.over?).to be_truthy
        expect(game.won?).to be_falsey
        expect(game.lost?).to be_truthy

        expect(game.lives_left).to eq 0

        expect(game.solved_char_status).to eq [ false, false, false, false ]
      end
    end

    context "after 4 correct guesses" do
      let(:guesses) { ['R', 'U', 'B', 'Y'] }

      it "is won" do
        expect(game.over?).to be_truthy
        expect(game.won?).to be_truthy
        expect(game.lost?).to be_falsey

        expect(game.lives_left).to eq 4

        expect(game.solved_char_status).to eq [ true, true, true, true ]
      end
    end
  end
end
