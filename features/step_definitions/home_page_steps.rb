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
