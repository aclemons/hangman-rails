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
