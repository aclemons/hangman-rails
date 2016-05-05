class GuessesController < ApplicationController
  def create
    game_id = params[:game_id]
    @make_guess = MakeGuess.new(game_id, guess_params[:letter])

    if @make_guess.call
      respond_to do |format|
        format.html { redirect_to @make_guess.game }
        format.json { head :created, location: guess_url(@make_guess.guess) }
      end
    else
      @make_guess.errors.add(Game.model_name.human, I18n.t("GAME_ALREADY_OVER", { :game_id => game_id.to_s })) if @make_guess.game.over?

      flash[:danger] = @make_guess.errors.keys.map { |k| "#{k}: #{@make_guess.errors[k].to_sentence}"}.to_sentence

      respond_to do |format|
        format.html { redirect_to Game.find(params[:game_id]) }
        format.json { render json: @make_guess.errors, status: :bad_request }
      end
    end
  end

  private

  def guess_params
    params.require(:guess).permit(:letter)
  end
end
