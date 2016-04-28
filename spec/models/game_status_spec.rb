#
# Copyright (C) 2016 Powershop New Zealand Ltd
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
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
