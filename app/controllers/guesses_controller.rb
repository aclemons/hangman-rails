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
class GuessesController < ApplicationController
  def create
    @make_guess = MakeGuess.new(params[:game_id], guess_params[:letter])

    if @make_guess.call
      respond_to do |format|
        format.html { redirect_to @make_guess.game }
        format.json { head :created, location: guess_url(@make_guess.guess) }
      end
    else
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
