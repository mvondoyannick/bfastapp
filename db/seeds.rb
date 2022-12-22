# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
Horaire.create([
  {departure: DateTime.now.change(hour: 04, min: 00)},
  {departure: DateTime.now.change(hour: 05, min: 00)},
  {departure: DateTime.now.change(hour: 06, min: 00)},
  {departure: DateTime.now.change(hour: 07, min: 00)},
  {departure: DateTime.now.change(hour: 8, min: 00)}, 
  {departure: DateTime.now.change(hour: 9, min: 00)},
  {departure: DateTime.now.change(hour: 10, min: 00)},
  {departure: DateTime.now.change(hour: 11, min: 00)},
  {departure: DateTime.now.change(hour: 12, min: 00)},
  {departure: DateTime.now.change(hour: 13, min: 00)},
  {departure: DateTime.now.change(hour: 14, min: 00)},
  {departure: DateTime.now.change(hour: 15, min: 00)},
  {departure: DateTime.now.change(hour: 16, min: 00)},
  {departure: DateTime.now.change(hour: 17, min: 00)},
  {departure: DateTime.now.change(hour: 18, min: 00)},
  {departure: DateTime.now.change(hour: 19, min: 00)},
])
puts "Done!"
