require 'sinatra'
require './war_deck'
enable :sessions


helpers do
    
    def set_up_game
        session[:deck] = Deck.new
        session[:deck].shuffle
        session[:player1] = Player.new "Player 1"
        session[:player2] = Player.new "Player 2"
        deal_cards
    end
    
    def deal_cards
        session[:player2].take session[:deck].draw
        while session[:deck].not_empty
            session[:player1].take session[:deck].draw
            
        end
    end
    
    def new_battle
        @cards_in_play = {}
        @cards_in_play[:player1] = Stack.new
        @cards_in_play[:player2] = Stack.new
        @results = ""
        @game_over = false
    end
    
    def take_turn_playing_cards(player, num=1)
        while num > 0
            if the_loser_is player
                @game_over = true
                print_losing_message_for player
                num = 0
            else
                @cards_in_play[player].take session[player].play_card
                num -= 1
            end
        end
    end
    
    def do_battle
        new_battle
        take_turn_playing_cards(:player1)
        take_turn_playing_cards(:player2)
        choose_the_winner
    end

    def choose_the_winner
        if !@game_over
            if (@cards_in_play[:player1].current_card.value > @cards_in_play[:player2].current_card.value)
                the_winner_is :player1
            elsif (@cards_in_play[:player2].current_card.value > @cards_in_play[:player1].current_card.value)
                the_winner_is :player2
            else
                war
            end
        end
    end
    
    # if the players tie, they go to war
    def war
        declare_war
        # each player puts one card face down and another card face up, playing 2 cards total
        take_turn_playing_cards(:player1, 2)
        take_turn_playing_cards(:player2, 2)
        choose_the_winner
    end
    
    def declare_war
        @results += "#{ session[:player1].name } plays #{ @cards_in_play[:player1].current_card.description } and #{ session[:player2].name } plays #{ @cards_in_play[:player2].current_card.description }.<br>THIS MEANS WAR!<br>"
    end
    
    def the_winner_is winner
        if winner == :player1
            loser = :player2
        else
            loser = :player1
        end
        @results += "#{ session[winner].name } wins with #{ @cards_in_play[winner].current_card.description } versus #{ @cards_in_play[loser].current_card.description }.<br>"
        collect_pot
        while @pot.not_empty
            session[winner].take @pot.draw
            @results += "#{ session[winner].name } gains #{ session[winner].current_card.description }.<br>"
        end
        output_number_of_cards
    end

    def output_number_of_cards
        @results += "#{ session[:player1].name } has #{ session[:player1].num_of_cards_left } cards.<br>#{ session[:player2].name } has #{ session[:player2].num_of_cards_left } cards.<br>"
    end
    
    def the_loser_is player
        session[player].loses
    end

    # combines the cards played by players 1 and 2 into a pot and shuffles them
    def collect_pot
        @pot = Stack.new
        grab_cards_from :player1
        grab_cards_from :player2
        @pot.shuffle
    end
    
    def grab_cards_from player
        while @cards_in_play[player].not_empty
            @pot.take @cards_in_play[player].draw
        end
    end
    
    def print_losing_message_for player
        @results += "#{ session[player].name } loses!<br>GAME OVER<br><a href='/'>Play Again</a><br>"
    end

    # if neither player has lost, it asks to continue
    # if one of the players has lost, it asks to play again
    def ask_to_continue
        if !@game_over
            if the_loser_is :player1
                print_losing_message_for :player1
            elsif the_loser_is :player2
                print_losing_message_for :player2
            else
                @results += "<a href='/play/battle'>Click to play next turn.</a>"
            end
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
