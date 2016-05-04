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
