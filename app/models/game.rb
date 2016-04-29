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
class Game < ActiveRecord::Base
  before_save { self.game_status_id = GameStatus::STATUS_NEW unless self.game_status_id }
  validates :word, presence: true, length: { minimum: 3, maximum: 50 }
  validates :lives, presence: true, :numericality => { :greater_than_or_equal_to => 1 }
  validates :game_status_id, presence: true

  has_many   :guesses
  belongs_to :game_status

  def game_over?
    won? or lost?
  end

  def won?
    solved_char_status.all?
  end

  def solved_char_status
    # returns [ true, false, false ] etc
    word.upcase.chars.to_a.map do |c|
      guesses.any? { |guess| guess.letter == c }
    end
  end

  def lost?
    lives_left <= 0
  end

  def wrong_guess_count
    chars = word.upcase.chars
    guesses.reject { |guess| chars.include?(guess.letter) }.count
  end

  def lives_left
    lives - wrong_guess_count
  end

  def update_game_status!
    self.game_status_id = if won?
                       GameStatus::STATUS_WON
                     elsif lost?
                       GameStatus::STATUS_LOST
                     else
                       GameStatus::STATUS_IN_PROGRESS
                     end
  end
end
