class Game < ActiveRecord::Base
  DEFAULT_LIVES = 7

  scope :with_game_status, -> (status) { where game_status: status }

  before_validation { self.game_status_id = GameStatus::STATUS_NEW unless self.game_status_id }
  validates :word, presence: true, length: { minimum: 3, maximum: 50 }
  validates :lives, presence: true, :numericality => { :greater_than_or_equal_to => 1 }
  validates :game_status_id, presence: true

  has_many   :guesses
  belongs_to :game_status

  def over?
    won? || lost?
  end

  def won?
    solved_char_status.all?
  end

  def solved_char_status
    # returns [ true, false, false ] etc
    upcase_chars.map do |c|
      guesses.any? { |guess| guess.letter == c }
    end
  end

  def lost?
    lives_left <= 0
  end

  def lives_left
    lives - wrong_guess_count
  end

  def update_status!
    self.game_status_id = calculate_status
  end

  private

  def wrong_guess_count
    guesses.reject { |guess| upcase_chars.include?(guess.letter) }.count
  end

  def upcase_chars
    @upcase_chars ||= word.upcase.chars
  end

  def calculate_status
    if won?
      GameStatus::STATUS_WON
    elsif lost?
      GameStatus::STATUS_LOST
    else
      GameStatus::STATUS_IN_PROGRESS
    end
  end
end
