class GamesController < ApplicationController
  def index
    @games = Game.where(nil)

    filtering_params.each do |key, value|
      @games = @games.public_send("with_#{key}", value) if value.present?
    end

    @games = @games.paginate(page: params[:page]).order('created_at ASC')

    respond_to do |format|
      format.html
      format.json { set_pagination_header(@games) }
    end
  end

  def show
    @game = Game.find(params[:id])

    respond_to do |format|
      format.html
      format.json
    end
  end

  def new
    @game = Game.new(lives: Game::DEFAULT_LIVES)
  end

  def create
    @game = Game.new(user_params.merge(game_status_id: GameStatus::STATUS_NEW))

    if @game.word.nil? || @game.word.empty?
      choose_random_word = ChooseRandomWord.new

      if choose_random_word.call
        @game.word = choose_random_word.word
      end
    end

    if @game.save
      respond_to do |format|
        format.html { redirect_to(@game) }
        format.json { render :show, status: :created, location: game_url(@game) }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: @game.errors, status: :bad_request }
      end
    end
  end

  private

  def user_params
    params.require(:game).permit(:lives, :word)
  end

  def filtering_params
    params.slice(:game_status)
  end
end
