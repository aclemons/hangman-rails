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

When(/^I am on the home page$/) do
  visit root_path

  expect(page).to have_content('Home')
  expect(page).to have_content('Game List')
  expect(page).to have_content('Help')
  expect(page).to have_content('Create Game')
end

Then(/^I can create a new game$/) do
  click_link('Create Game')

  fill_in('game[word]', :with => 'cucumber')
  fill_in('game[lives]', :with => 4)

  click_button('Save')
end

Given(/^some games exist$/) do
  @game1 = Game.create!(word: 'ruby', lives: 4)
  @game2 = Game.create!(word: 'timmi', lives: 6)
end

Then(/^I can view the list of games$/) do
  click_link('Game List')

  expect(page).to have_content(@game1.id.to_s)
  expect(page).to have_content(@game1.lives.to_s)
  expect(page).to have_content(@game2.id.to_s)
  expect(page).to have_content(@game2.lives.to_s)
end

Then(/^I can view the game help$/) do
  click_link('Help')

  expect(page).to have_content("Background information on hangman")
end

Then(/^I can create a random game$/) do

  click_link('Create Game')

  fill_in('game[lives]', :with => 4)

  click_button('Save')

  expect(page).to have_content("[  ]")
  expect(page).to have_content("You have 4 lives left:")
end
