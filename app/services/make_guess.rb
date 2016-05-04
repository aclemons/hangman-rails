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
  extend ActiveModel::Translation

  attr_reader :errors, :game, :guess, :letter, :game_id

  def initialize(game_id, letter)
    @game_id, @letter = game_id, letter
    @errors = ActiveModel::Errors.new(self)
  end

  def call
    begin
      Game.transaction do
        @game = Game.find(game_id)

        if game.over?
          errors.add(MakeGuess.human_attribute_name(:state), I18n.t("GAME_ALREADY_OVER", { :game_id => game_id.to_s }))
          raise ActiveRecord::Rollback
        end

        @guess = game.guesses.create(letter: letter)

        unless guess.valid?
          guess.errors.each { |attribute, error| errors.add(attribute, error) }

          raise ActiveRecord::Rollback
        end

        game.update_status!

        unless game.save
          game.errors.each { |attribute, error| errors.add(attribute, error) }
          raise ActiveRecord::Rollback
        end

        return true
      end
    rescue ActiveRecord::RecordNotUnique => e
      errors.add(MakeGuess.human_attribute_name(:letter), I18n.t("LETTER_ALREADY_USED", { :letter => letter.to_s }))
    end

    false
  end
end
