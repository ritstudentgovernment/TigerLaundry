# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

gv400     = Facility.create({name: 'Global Village 400', washers: 6,  driers: 6})
ellingson = Facility.create({name: 'Ellingson',          washers: 20, driers: 20})
gibson    = Facility.create({name: 'Gibson',             washers: 8,  driers: 8})
solH      = Facility.create({name: 'Sol Heumann',        washers: 20, driers: 20})
gleason   = Facility.create({name: 'Gleason',            washers: 22, driers: 22})
reshallA  = Facility.create({name: 'Residence Hall A',   washers: 6,  driers: 6})
reshallB  = Facility.create({name: 'Residence Hall B',   washers: 6,  driers: 6})
reshallC  = Facility.create({name: 'Residence Hall C',   washers: 6,  driers: 6})
