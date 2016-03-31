# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

admin=User.create!(admin: true, email: "foton@centrum.cz", token: "R3plac3MeImm3d1a7elly")
bunny1=User.create!(admin: true, email: "bunny@centrum.cz")

hyde_park=Location.create!(name: "Hide and seek park", city: "London", user: bunny1, top_left_coordinate_str: "51.5118883N, 0.1905369W" ,bottom_right_coordinate_str: "51.5028867N, 0.1512694W")
olomouc=Location.create!(name: "Olomouc", city: "Olomouc",   description: "Metropolis of Haná", user: bunny1, top_left_coordinate_str: "49.6124894N, 17.2159669E" ,bottom_right_coordinate_str: "49.5604067N, 17.3100375E")

Egg.create!(size: 2,  name: "Round thing from angular things", location: hyde_park,  user: bunny1)
Egg.create!(size: 1, name: "Terminated round thing from angular things", location: hyde_park, user: bunny1)
Egg.create!(size: 4, name: "Fabergé: Smaragd and gold", location: olomouc, user: admin)
Egg.create!(size: 4, name: "Fabergé: Safir and silver", location: olomouc, user: admin)

