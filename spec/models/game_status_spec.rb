require 'rails_helper'

RSpec.describe GameStatus, type: :model do
  let(:game_status) { GameStatus.new(id: 1, name: 'Test') }

  context "#valid?" do
    it "is valid when all fields are valid" do
      expect(game_status.valid?).to be_truthy
    end

    it "is invalid when name is missing" do
      game_status.name = nil
      expect(game_status.valid?).to be_truthy
    end

    it "is invalid when id is outside range" do
      game_status.id = 7
      expect(game_status.valid?).to be_falsey
    end

    it "is invalid when id is not numeric" do
      game_status.id = 'id'
      expect(game_status.valid?).to be_falsey
    end
  end
end
