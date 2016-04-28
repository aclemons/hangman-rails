json.results do
  json.array! @games do |game|
    json.id               game.id
    json.word             game.word
    json.lives            game.lives
    json.lives_remaining  game.lives_left
    json.status           game.game_status.id

    json.guesses do
      json.array! game.guesses.map(&:letter)
    end
  end
end
