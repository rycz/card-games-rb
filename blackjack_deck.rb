class Card
    
    def initialize(name, suit)
        @name = name
        @suit = suit
    end
    
    def description
        "the #{ @name } of #{ @suit }"
    end
    
    def value
        case @name[0]
            when "J" then 10
            when "Q" then 10
            when "K" then 10
            when "A" then 11
            else @name.to_i
        end
    end
    
end


# this class is for a deck of 52 cards
class Deck
    
   def initialize
       @cards = []
       suits = %w[ Hearts Diamonds Clubs Spades ]
       names = %w[ Ace 2 3 4 5 6 7 8 9 10 Jack Queen King ]
       suits.each do |suit|
           names.each do |name|
               @cards << Card.new(name, suit)
           end
       end
   end
   
   def shuffle
       @cards.shuffle!
   end
   
   def draw
       @cards.pop
   end

end


# this class is for a group of cards that does not start out as a full deck
class Hand < Deck
    
    def initialize
        @cards = []
    end
    
    def cards
        @cards
    end
    
    def num_cards
        @cards.size
    end
    
    # adds a card to the bottom of the stack
    def take new_card
        @cards << new_card
    end
    
    # this shows the card that most recently added to the stack
    def current_card
        @cards[-1]
    end
    
    def value
        value = 0
        aces = 0
        @cards.each do |card|
            if card.value == 11
                aces += 1
            end
            value += card.value
        end
        # if there's an Ace and the total value is greater than 21, the Ace = 1 instead of 11
        if value > 21 and aces > 0
            num = 0
            while num < aces
                if value > 21
                    value = value - 10
                end
                num += 1
            end
        end
        value
    end
    
end


class Player
    
    def initialize(name)
        @name = name
        @hand = Hand.new
    end
    
    def name
        @name
    end
    
    def hand
        @hand.cards
    end
    
    def hand_value
        @hand.value
    end
    
    def num_cards_in_hand
        @hand.num_cards
    end
    
    def take new_card
        @hand.take new_card
    end
    
    def current_card
        @hand.current_card
    end

end
