#
# Copyright (C) 2016 Powershop New Zealand Ltd
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Given(/^I have started a game$/) do
  @game = Game.create!(word: 'ruby', lives: 4)

  visit "games/#{@game.id.to_s}"
end

When(/^I guess a correct letter$/) do
  fill_in('guess[letter]', :with => "R")

  click_button('Guess')
end

Then(/^I see the letter as part of the word$/) do
  expect(page).to have_content("r _ _ _")
end

Then(/^I see the letter in the list of used letters$/) do
  expect(page).to have_content("[ R ]")
end

Then(/^I have lost no lives$/) do
  expect(page).to have_content("4 lives left")
end

When(/^I guess an incorrect letter$/) do
  fill_in('guess[letter]', :with => "X")

  click_button('Guess')
end

Then(/^I have lost one life$/) do
  expect(page).to have_content("3 lives left")
end

Then(/^I see the incorrect letter in the list of used letters$/) do
  expect(page).to have_content("[ X ]")
end

Then(/^I do not see the letter as part of the word$/) do
  expect(page).to have_content("_ _ _ _")
end

When(/^I guess an incorrect letter with one life left$/) do
  @game.lives = 1
  @game.save!

  fill_in('guess[letter]', :with => "X")

  click_button('Guess')
end

Then(/^I am notified that the game is over$/) do
  expect(page).to have_content("Game over!")
end

Then(/^I see the word I was trying to guess$/) do
  expect(page).to have_content("Word was ruby")
end

When(/^I guess correctly the last missing letter$/) do
  [ 'R', 'u', 'b' ].each { |letter| @game.guesses.create!(letter: letter) }

  fill_in('guess[letter]', :with => "y")
  click_button('Guess')
end

Then(/^I am notified that the game was won$/) do
  expect(page).to have_content("You win!")
end

When(/^I guess a duplicate letter$/) do
  @game.guesses.create!(letter: 'R')

  fill_in('guess[letter]', :with => "r")

  click_button('Guess')
end

Then(/^I am notified that the letter has already been used$/) do
  expect(page).to have_content("letter: has already been taken")
end

When(/^I guess a non\-letter$/) do
  fill_in('guess[letter]', :with => "6")

  click_button('Guess')
end

Then(/^I am notified that the guess must be a letter$/) do
  expect(page).to have_content("letter: is invalid")
end
