require 'sinatra'
require './war_deck'
enable :sessions


helpers do
    
    def set_up_game
        session[:deck] = Deck.new
        session[:deck].shuffle
        session[:player1] = Stack.new
        session[:player2] = Stack.new
        deal_cards
    end
    
    def deal_cards
        while session[:deck].not_empty
            session[:player1].take session[:deck].draw
            session[:player2].take session[:deck].draw
        end
    end
    
    def new_battle
        @p1_played = Stack.new
        @p2_played = Stack.new
        @results = ""
        @game_over = false
    end
    
    def player1_plays_card num=1
        while num > 0
            if player1_loses
                @game_over = true
                @results += "Player 1 loses!<br>GAME OVER<br>"
                num = 0
            else
                @p1_played.take session[:player1].play_card
                num -= 1
            end
        end
    end
    
    def player2_plays_card num=1
        while num > 0
            if player2_loses
                @game_over = true
                @results += "Player 2 loses!<br>GAME OVER<br>"
                num = 0
            else
                @p2_played.take session[:player2].play_card
                num -= 1
            end
        end
    end
    
    def do_battle
        new_battle
        player1_plays_card
        player2_plays_card
        choose_the_winner
    end

    def choose_the_winner
        if !@game_over
            if (@p1_played.current_card.value > @p2_played.current_card.value)
                player1_wins
            elsif (@p2_played.current_card.value > @p1_played.current_card.value)
                player2_wins
            else
                war
            end
        end
    end
    
    # if the players tie, they go to war
    def war
        declare_war
        # each player puts one card face down and another card face up
        player1_plays_card 2
        player2_plays_card 2
        choose_the_winner
    end
    
    def declare_war
        @results += "Player 1 plays #{ @p1_played.current_card.description } and Player 2 plays #{ @p2_played.current_card.description }.<br>THIS MEANS WAR!<br>"
    end
    
    def player1_wins
        @results += "Player 1 wins with #{ @p1_played.current_card.description } versus #{ @p2_played.current_card.description }.<br>"
        collect_pot
        while @pot.not_empty
            session[:player1].take @pot.draw
            @results += "Player 1 gains #{ session[:player1].current_card.description }.<br>"
        end
        output_number_of_cards
    end
    
    def player2_wins
        @results += "Player 2 wins with #{ @p2_played.current_card.description } versus #{ @p1_played.current_card.description }.<br>"
        collect_pot
        while @pot.not_empty
            session[:player2].take @pot.draw
            @results += "Player 2 gains #{ session[:player2].current_card.description }.<br>"
        end
        output_number_of_cards
    end

    def output_number_of_cards
        @results += "Player 1 has #{ session[:player1].deck_size } cards.<br>Player 2 has #{ session[:player2].deck_size } cards.<br>"
    end
    
    def player1_loses
        !session[:player1].not_empty
    end
    
    def player2_loses
        !session[:player2].not_empty
    end

    # combines the cards played by players 1 and 2 into a pot and shuffles them
    def collect_pot
        @pot = Stack.new
        while @p1_played.not_empty
            @pot.take @p1_played.draw
        end
        while @p2_played.not_empty
            @pot.take @p2_played.draw
        end
        @pot.shuffle
    end

    # if neither player has lost, it asks to continue
    # if one of the players has lost, it asks to play again
    def ask_to_continue
        if !@game_over
            if player1_loses
                @results += "Player 1 loses!<br>GAME OVER<br><a href='/'>Play Again</a><br>"
            elsif player2_loses
                @results += "Player 2 loses!<br>GAME OVER<br><a href='/'>Play Again</a><br>"
            else
                @results += "<a href='/play/battle'>Click to play next turn.</a>"
            end
        else
            @results += "<a href='/'>Play Again</a>"
        end
    end

end


get '/' do
    set_up_game
    redirect to('/play/cards')
end

get '/play/:battle' do

    do_battle
    ask_to_continue

    @results

end
