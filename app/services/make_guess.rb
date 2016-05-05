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

      if game.over?
        errors.add(Game.model_name.human, I18n.t("GAME_ALREADY_OVER", { :game_id => game_id.to_s }))

        return false
      end

      @guess = game.guesses.create(letter: letter)

      unless guess.valid?
        copy_errors(guess)
        return false
      end

      game.update_status!

      unless game.save!
        copy_errors(game)
        return false
      end
    end

    true
  end

  private

  def copy_errors(source)
    source.errors.each { |attribute, error| errors.add(attribute, error) }
  end
end
