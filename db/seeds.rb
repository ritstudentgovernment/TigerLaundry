# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

gv400 = Facility.create({name: 'Global Village 400', washers: 6, driers: 6})
gv400submission = Submission.create({washers: 50, driers: 50, facility_id: gv400})
gv400submission = Submission.create({washers: 25, driers: 25, facility_id: gv400})