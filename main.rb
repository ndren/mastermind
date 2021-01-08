# frozen_string_literal: true

# Generate code to be broken.
class Code
  attr_reader :code

  def random
    rand(1..9)
  end

  def initialize
    @code = ''
    4.times do |_i|
      @code += random.to_s
    end
  end
end

# Run the game.
class Game
  def initialize(code)
    @code = code
  end

  def diff(a, b)
    tally = b.clone
    exact_same = 0
    same = 0
    (0..3).each do |i|
      exact_same += 1 if a[i] == b[i]
    end
    a.split('').each do |i|
      same += 1 if b.include?(i)
      tally.sub!(i, '')
    end
    same -= exact_same
    "#{exact_same}! #{same}?"
  end

  def move!(guess)
    diff(@code, guess)
  end
end

choice = nil
puts 'Welcome to Mastermind, the game where you make (or break) a code!'
until %w[1 2].include?(choice)
  puts 'Will you be the code breaker (1) or code maker (2)?'
  choice = gets.chomp
end

case choice
when '1'
  code_breaker = 'Player'
  puts 'The code can be any four-digit set using numbers 1-9 (e.g. 1233, 7677 but not 8010 or 654).'
  puts 'You will be told whether how many numbers in your guess are correct and in the right spot (!), ' \
       'or just correct (?), but not where they are.'
  puts 'Good luck!'
when '2'
  code_breaker = 'Computer'
  puts 'The code can be any four-digit set using numbers 1-9 (e.g. 1233, 7677 but not 8010 or 654).'
  puts 'The computer will know how many numbers in their guess are correct and in the right spot (!), ' \
       'or just correct (?), but not where they are.'
  puts 'Good luck!'
end

def validate_code(code)
  if code.include?('0')
    puts 'Zero is not allowed.'
    return false
  elsif code.length != 4
    puts 'The code should be of length four.'
    return false
  end
  true
end

tries_left = 12
if code_breaker == 'Player'
  player_game = Game.new(Code.new.code)
  while tries_left != 0
    guess = gets.chomp
    next unless validate_code(guess)

    result = player_game.move!(guess)
    if result == '4! 0?'
      puts 'You win!'
      break
    end
    puts result
    tries_left -= 1
    print 'You ran out of guesses.' if tries_left.zero?
  end
end

if code_breaker == 'Computer'
  puts 'Please pick a code for the computer to guess.'
  code = gets.chomp
  code = gets.chomp until validate_code(code)

  computer_game = Game.new(code)
  options = %w[1 1 1 1]
  tries_left = 12
  guess = nil
  guesses = []
  computer_won = false

  while tries_left != 0
    guess = options.shuffle.join while guesses.include?(guess) || guess.nil?
    guesses.append(guess)
    result = computer_game.move!(guess)

    puts "The computer guessed #{guess}."
    puts result
    sleep(0.5)

    # Increment guess by 1 depending on the number of correct guesses.
    guess_score = result[0].to_i + result[3].to_i
    (4 - guess_score).times do |i|
      options[i] = (options[i].to_i + 1).to_s
    end
    tries_left -= 1

    if result == '4! 0?'
      computer_won = true
      break
    end
  end

  if computer_won
    puts 'The Computer guessed the code!'
  else
    puts 'The Computer ran out of tries!'
  end
end
