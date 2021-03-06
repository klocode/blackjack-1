require 'tty'
require_relative 'deck'

class Game

  attr_accessor   :deck,
                  :gambler_hand,
                  :casino_hand,
                  :prompt

  def initialize
    @deck = Deck.new
    @prompt = TTY::Prompt.new
    @gambler_hand = []
    @casino_hand = []
    deal
    read_dealer_hand
    read_player_hand
  end

  def deal
    2.times do
      @gambler_hand << deck.draw
      @casino_hand << deck.draw
    end
  end

  def read_dealer_hand
    puts "The dealer has #{casino_hand[0]} face up"
    if casino_hand_total == 21
      puts "Blackjack house wins! They were also holding #{casino_hand[1]}"
      ask_for_rematch
    end
  end

  def read_player_hand
    puts "You have:"
      gambler_hand.each do |card|
        puts card
      end
    if gambler_hand_total == 21
      puts "Blackjack! You win!"
      ask_for_rematch
    end
      game_loop
  end

  def dealer_turn
    if casino_hand_total == 21
       puts "The house hit 21!"
       win_conditions
       ask_for_rematch
    elsif casino_hand_total.between?(16, 20)
      puts "They are choosing to stay with #{casino_hand_total}."
      win_conditions
    elsif casino_hand_total > 21
      puts "Busted!!! House sucks!"
    else
      dealer_hit
    end
    ask_for_rematch
  end

  def casino_hand_reader
    puts "The dealer has #{casino_hand[0]} and #{casino_hand[1]}."
    dealer_turn
  end

  def hit_or_stay
    hit_or_stay_switch = prompt.select("Would you like to hit or stay?", {:hit => true, :stay => false})
    if hit_or_stay_switch
      hit
      gambler_win_or_bust
    else
      puts "You're choosing to stay"
      casino_hand_reader
    end
  end

  def gambler_hand_total
    gambler_hand.inject(0){|sum, card| sum + card.value}
  end

  def casino_hand_total
    casino_hand.inject(0){|sum, card| sum + card.value}
  end

  def gambler_hand_counter
    gambler_hand.size
  end

  def casino_hand_counter
    casino_hand.size
  end

  def hit
    gambler_hand << deck.draw
    puts gambler_hand.last
  end

  def bust
    gambler_hand_total > 21
  end

  def gambler_win_or_bust
    if gambler_hand_total > 21
      puts "Busted! You lost."
      ask_for_rematch
    elsif gambler_hand_total < 21
      puts gambler_hand_total
    else
      puts "Bingo! That's 21!"
      win_conditions
      ask_for_rematch
    end
  end

  def game_loop
    until bust
      hit_or_stay
    end
  end

  def tie
    if gambler_hand_counter > casino_hand_counter
      puts "You win, you had #{gambler_hand_counter} cards and the dealer only had #{casino_hand_counter}."
    elsif
      gambler_hand_counter < casino_hand_counter
        puts "You lost, you had #{gambler_hand_counter} cards and the dealer had #{casino_hand_counter}."
    else
      puts "Double tie. We'll give that one to ya!"
    end
  end

  def win_conditions
    if gambler_hand_counter == 6 && gambler_hand_total < 21
      puts "You win with 6 cards. Rare but it can happen!"
    end
    if gambler_hand_total > casino_hand_total
      puts "You beat the house. Good win."
    elsif gambler_hand_total == casino_hand_total
      tie
    else
      puts "The dealer won. Boo..."
    end
  end

  def dealer_hit
    casino_hand << deck.draw
    puts "The dealer drew a #{casino_hand.last}"
    dealer_turn
  end

  def ask_for_rematch
    desire = prompt.yes?("Would you like a rematch?")
    if desire
      Game.new.play
    else
      puts "Cash me ousside, how bout dat"
      exit
    end
  end
end

Game.new
