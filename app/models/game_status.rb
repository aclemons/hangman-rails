class GameStatus < ActiveRecord::Base
  self.primary_key = "id"

  STATUS_NEW = 0
  STATUS_IN_PROGRESS = 1
  STATUS_LOST = 2
  STATUS_WON = 3

  validates :id, numericality: { only_integer: true, :greater_than_or_equal_to => STATUS_NEW, :less_than_or_equal_to => STATUS_WON }
end
