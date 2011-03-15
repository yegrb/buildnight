# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
if Rails.env.development?
  groceries = List.create(:title => "Groceries")
  groceries.items.create(:text => "oranges")
  groceries.items.create(:text => "apples")
  groceries.items.create(:text => "crackers")
  groceries.items.create(:text => "wheatbix")

  errands = List.create(:title => "Errands")
  errands.items.create(:text => "get groceries")
  errands.items.create(:text => "pickup parcel")
  errands.items.create(:text => "wash the car")

  favs = List.create(:title => "Favourite Albums")
  favs.items.create(:text => "Tron: Legacy")
  favs.items.create(:text => "Reintegration Time")
  favs.items.create(:text => "Boxer")
  favs.items.create(:text => "The King is Dead")

  gems = List.create(:title => "Winning RubyGems")
  gems.items.create(:text => "rails")
  gems.items.create(:text => "sinatra")
  gems.items.create(:text => "rack")
  gems.items.create(:text => "bundler")
  gems.items.create(:text => "devise")
  gems.items.create(:text => "cancan")
end
