class Guess < ActiveRecord::Base
  belongs_to :game

  default_scope -> { order(created_at: :asc) }

  before_validation { self.letter = letter.upcase }

  validates :letter, presence: true, length: { maximum: 1 },
                     format: { with: /\A[[:alpha:]]\z/},
                     uniqueness: { scope: [:game_id] }
end
