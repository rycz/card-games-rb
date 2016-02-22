require 'sinatra'
require './blackjack_deck'
enable :sessions



helpers do
    
    def set_up_game
        session[:deck] = Deck.new
        session[:deck].shuffle
        create_list_of_players
        session[:dealer] = Player.new "Dealer"
        session[:player] = Player.new "Player"
        session[:results] = ""
        deal_cards
    end
    
    # creates an array of the player symbol keys for coding easy loops
    def create_list_of_players
        @players = [ :dealer, :player ]
    end
    
    # each player starts with two cards
    def deal_cards
        @players.each do |player|
            num = 0
            while num < 2
                deal_card_to player
                num += 1
            end
        end
    end
    
    def deal_card_to the_chosen
        session[the_chosen].take session[:deck].draw
        # the dealer lays his first card face down
        if the_chosen == :dealer and session[the_chosen].num_cards_in_hand == 1
            session[:results] += "#{ session[:dealer].name } lays one card face down.<br>"
        else
            session[:results] += "#{ session[the_chosen].name } receives #{ session[the_chosen].current_card.description }.<br>"
        end
    end
    
    def play_blackjack
        # if the player has Blackjack, he automatically stands
        if has_blackjack :player
            dealers_turn
        elsif (params[:choice] == 'hit')
            session[:results] += "#{ session[:player].name } chose to hit.<br>"
            deal_card_to :player
            # if the player has Blackjack, he automatically stands
            if has_blackjack :player
                dealers_turn
            # the player automatically loses if he goes bust
            elsif goes_bust :player
                game_over
            # the player didn't get Blackjack and didn't go bust, so the game continues
            else
                show_hand_value :player
                choose_the_next_move
            end
        elsif (params[:choice] == 'stand')
            session[:results] += "#{ session[:player].name } stands.<br>"
            dealers_turn
        # if the cards were just dealt and the player doesn't have Blackjack, ask for his next move
        else
            choose_the_next_move
        end
    end
    
    def dealers_turn
        # the first thing the dealer does is flip over the card he laid face down
        if session[:dealer].num_cards_in_hand == 2
            session[:results] += "#{ session[:dealer].name } flips over the card. It's #{ session[:dealer].hand[0].description }.<br>"
        end
        if has_blackjack :dealer
            pick_a_winner
            game_over
        # the player wins if the dealer goes bust
        elsif goes_bust :dealer
            session[:results] += "You win!<br>"
            game_over
        # the dealer hits for any hand with a value less than 17
        elsif session[:dealer].hand_value < 17
            session[:results] += "#{ session[:dealer].name } chooses to hit.<br>"
            deal_card_to :dealer
            dealers_turn
        # the dealer stands for any hand with a value greater than or equal to 17
        # soft 17s (where Ace = 11) are not hit on
        else
            session[:results] += "#{ session[:dealer].name } stands.<br>"
            show_hand_value :dealer
            pick_a_winner
        end
    end
    
    def pick_a_winner
        if session[:player].hand_value == session[:dealer].hand_value
            session[:results] += "It's a tie!<br>"
        elsif session[:player].hand_value > session[:dealer].hand_value
            session[:results] += "You win!<br>"
        else
            session[:results] += "You lose!<br>"
        end
        game_over
    end
    
    # checks if a player has gone bust
    def goes_bust the_chosen
        if session[the_chosen].hand_value > 21
            session[:results] += "#{ session[the_chosen].name } goes bust.<br>"
            true
        else
            false
        end
    end
    
    # checks if a player has Blackjack
    def has_blackjack the_chosen
        if session[the_chosen].hand_value == 21
            session[:results] += "#{ session[the_chosen].name } has Blackjack!<br>"
            true
        else
            false
        end
    end
    
    # this prints each card in each player's hand. useful for testing.
    def print_cards
        @players.each do |player|
            session[player].hand.each do |card|
                session[:results] += "#{ session[player].name } has #{ card.description }.<br>"
            end
        end
    end
    
    # show the value of a player's hand
    def show_hand_value the_chosen
        session[:results] += "#{ session[the_chosen].name }'s hand has a value of #{ session[the_chosen].hand_value }.<br>"
    end
    
    def choose_the_next_move
        session[:ask] = "<a href='/play/hit'>Hit</a> or <a href='/play/stand'>Stand</a>?"
    end
    
    def game_over
        session[:ask] = "<a href='/'>Play Again</a>"
    end
    
end


get '/' do
    set_up_game
    redirect to('/play/cards')
end

get '/play/:choice' do
    create_list_of_players
    play_blackjack
    session[:results] + session[:ask]
end
