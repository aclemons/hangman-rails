require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  context "#index" do
    describe "GET index" do
      it "assigns @games" do
        get :index
        expect(assigns(:games)).to eq []
      end

      it "renders the index template" do
        get :index
        expect(response).to render_template("index")
      end
    end
  end

  context "#create" do
    describe "POST create" do
      it "renders the game template" do
        post :create, game: { lives: 4, word: 'timmi' }
        expect(assigns(:game)).to be_truthy
        expect(assigns(:game).word).to eq 'timmi'
        expect(assigns(:game).lives).to eq 4

        expect(response).to redirect_to(assigns(:game))
      end

      it "returns games json" do
        post :create, game: { lives: 4, word: 'timmi' }, :format => :json
        expect(assigns(:game)).to be_truthy
        expect(assigns(:game).word).to eq 'timmi'
        expect(assigns(:game).lives).to eq 4

        expect(response.content_type).to eq "application/json"
      end
    end
  end

  context "#show" do
    describe "GET show" do
      it "assigns the correct @game" do
        game = Game.create!(word: 'test', lives: 4)
        get :show, id: game.id
        expect(response).to render_template("show")
        expect(assigns(:game)).to eq game
      end
    end
  end

  context "#new" do
    describe "GET new" do
      it "assigns the correct @game" do
        game = Game.new
        get :new
        expect(response).to render_template("new")
        expect(assigns(:game)).to be_truthy
      end
    end
  end
end
