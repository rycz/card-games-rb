class Card
    
    def initialize(name, suit)
        @name = name
        @suit = suit
    end
    
    def description
        "The #{ @name } of #{ @suit }"
    end
    
    def value
        case @name[0]
            when "J" then 11
            when "Q" then 12
            when "K" then 13
            when "A" then 14
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
   
   def not_empty
       !@cards.empty?
   end
   
   def deck_size
       @cards.size
   end
    
end


# this class is for a group of cards that does not start out as a full deck
class Stack < Deck
    
    def initialize
        @cards = []
    end
    
    # takes a card from the top of the stack
    def play_card
        @cards.shift
    end
    
    # adds a card to the bottom of the stack
    def take new_card
        @cards << new_card
    end
    
    # this shows the card that most recently added to the stack
    def current_card
        @cards[-1]
    end
    
end
