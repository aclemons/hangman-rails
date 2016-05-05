class ChooseRandomWord
  attr_reader :word

  def call
    @word = lines.sample.chomp.strip
  end

  private

  def lines
    @@lines ||= IO.readlines(ENV["HANGMAN_WORD_LIST"])
  end
end

