require 'rails_helper'

RSpec.describe MakeGuess do

  let(:initial_lives) { 2 }
  let(:initial_status) { GameStatus::STATUS_NEW }
  let(:word) { "Ruby" }
  let(:game) { Game.new(word: word, lives: initial_lives) }
  let(:id) { game.id }

  before do
    game.game_status_id = initial_status
  end

  context "#new" do
    it "rejects an unknown game" do
      make_guess = MakeGuess.new(-1, 'k')
      expect { make_guess.call }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "#call" do
    before do
      game.save!
    end

    describe "at the start of a game" do
      it "decrements the lives after an incorrect guess" do
        make_guess = MakeGuess.new(id, 'k')

        expect(make_guess.call).to be_truthy

        expect(make_guess.errors.any?).to be_falsey

        game = Game.find(id)

        expect(game.lost?).to be_falsey
        expect(game.won?).to be_falsey
        expect(game.lives_left).to eq 1
        expect(game.solved_char_status).to eq [ false, false, false, false ]
        expect(game.game_status_id).to eq GameStatus::STATUS_IN_PROGRESS
      end
    end

    describe "during a game" do
      let(:initial_lives) { 1 }
      let(:initial_status) { GameStatus::STATUS_IN_PROGRESS }

      it "solving the word wins the game" do
        game.guesses.create!(letter: "R")
        game.guesses.create!(letter: "U")
        game.guesses.create!(letter: "B")

        make_guess = MakeGuess.new(id, 'y')

        expect(make_guess.call).to be_truthy

        expect(make_guess.errors.any?).to be_falsey

        game = Game.find(id)

        expect(game.lost?).to be_falsey
        expect(game.won?).to be_truthy
        expect(game.lives_left).to eq 1
        expect(game.solved_char_status).to eq [ true, true, true, true ]
        expect(game.game_status_id).to eq GameStatus::STATUS_WON
      end

      it "rejects guesses for a game which is already over" do
        game.guesses.create!(letter: "X")
        game.game_status_id = GameStatus::STATUS_LOST
        game.save!

        make_guess = MakeGuess.new(id, 'K')

        expect(make_guess.call).to be_falsey

        expect(make_guess.errors.any?).to be_truthy

        game = Game.find(id)

        expect(game.lost?).to be_truthy
        expect(game.won?).to be_falsey
        expect(game.lives_left).to eq 0
        expect(game.solved_char_status).to eq [ false, false, false, false ]
        expect(game.game_status_id).to eq GameStatus::STATUS_LOST

      end

      it "rejects invalid letters" do
        make_guess = MakeGuess.new(id, 'TT')

        expect(make_guess.call).to be_falsey

        expect(make_guess.errors.any?).to be_truthy

        game = Game.find(id)

        expect(game.lost?).to be_falsey
        expect(game.won?).to be_falsey
        expect(game.lives_left).to eq 1
        expect(game.solved_char_status).to eq [ false, false, false, false ]
        expect(game.game_status_id).to eq GameStatus::STATUS_IN_PROGRESS
      end

      it "rejects already used letter" do
        game.lives = 2
        game.save!

        game.guesses.create!(letter: "T")

        make_guess = MakeGuess.new(id, 'T')

        expect(make_guess.call).to be_falsey

        expect(make_guess.errors.any?).to be_truthy

        game = Game.find(id)

        expect(game.lost?).to be_falsey
        expect(game.won?).to be_falsey
        expect(game.lives_left).to eq 1
        expect(game.solved_char_status).to eq [ false, false, false, false ]
        expect(game.game_status_id).to eq GameStatus::STATUS_IN_PROGRESS
      end
    end

    describe "game is over" do
      let(:initial_lives) { 1 }
      let(:initial_status) { GameStatus::STATUS_IN_PROGRESS }

      it "rejects the guess" do
        make_guess = MakeGuess.new(id, 'k')

        expect(make_guess.call).to be_truthy

        expect(make_guess.errors.any?).to be_falsey

        game = Game.find(id)

        expect(game.lost?).to be_truthy
        expect(game.won?).to be_falsey
        expect(game.lives_left).to eq 0
        expect(game.solved_char_status).to eq [ false, false, false, false ]
        expect(game.game_status_id).to eq GameStatus::STATUS_LOST
      end
    end
  end
end
