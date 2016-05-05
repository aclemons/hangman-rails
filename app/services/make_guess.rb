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
class MakeGuess
  attr_reader :errors, :game, :guess, :letter, :game_id

  def initialize(game_id, letter)
    @game_id, @letter = game_id, letter

    # errors on a PORO
    # per documentation at http://api.rubyonrails.org/classes/ActiveModel/Errors.html
    @errors = ActiveModel::Errors.new(self)
  end

  def call
    Game.transaction do
      @game = Game.lock(true).find(game_id)

      return false if game.over?

      @guess = game.guesses.create(letter: letter)

      copy_errors(guess) && (return false) unless guess.valid?

      game.update_status!

      copy_errors(game) && (return false) unless game.save
    end

    true
  end

  private

  def copy_errors(source)
    source.errors.each { |attribute, error| errors.add(attribute, error) }
  end
end
