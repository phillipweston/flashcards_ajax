enable :sessions

get '/' do
  if session[:user_id]
    @decks = Deck.all
    erb :profile
  else
    erb :index
  end
end

get '/profile/:id' do |id|
   @gravatar = gravatar_url(current_user.email)

  @rounds = Round.where('user_id = ?', current_user.id)

  @topics = []

  @rounds.each do |round|
    card_id = round.guesses.last.card_id
    id = Card.find(card_id).deck_id
    @topics << Deck.find(id).topic
  end

  @decks = Deck.all
  erb :profile
end

get '/game/:topic_id' do |topic_id|
  @gravatar = gravatar_url(current_user.email)
	@user = User.find(session[:user_id])
	@user.rounds << Round.create
	@user.rounds.last.cards << Card.where('deck_id = ?', topic_id).shuffle
	guess = @user.guesses.where('round_id = ?', @user.rounds.last.id).first.destroy
	@card = Card.find(guess.card_id)

  erb :game
end

# card1 = user.guesses.where('round_id = ?', user.rounds.last.id).first.destroy
# @card = Card.find(card1.card_id

post '/game' do
  content_type 'json'

  user = User.find(session[:user_id])
  guess = user.guesses.where('round_id = ?', user.rounds.last.id).first.destroy
  card = Card.find(guess.card_id)
  previous_answer = card.answer
  correct = 0

  if card.correct?(params[:answer])
  	user.rounds.last.increment('correct').save
  	correct = 1
  else
  	user.rounds.last.increment('incorrect').save
  end

	guess = user.guesses.where('round_id = ?', user.rounds.last.id).first
  card = Card.find(guess.card_id)

  [correct, card.question, card.id, previous_answer].to_json
end
                                                                                                                                                                                                                                                                                                                                  



