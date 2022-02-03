# README

Exercise realized by Paulo Carmona, github: @pollcaz, email: pcarmonaz@gmail.com

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version: 2.7.4

* System dependencies: Rails 6.1

* Configuration

* Database creation: For this exercise we are using RAM memory loading lib/reading/readings.json  file when server is loading

* Database initialization: is not required

* How to run the test suite: bundle exec rspec spec

* Services (job queues, cache servers, search engines, etc.)

* How to run server: bundle exec rails s
** it will be loaded and listening on http://localhost:3000

* ...

# Note: this exercise contains all requirements decribed in the document
## Api endpoints
* POSTaction to create readings by device: /api/v1/device/readings, params: id as string, readings as an array of hashes with timestamp, count [key value], creates or add readings for a specific device
* GET action: /api/v1/device/count, params: id as string, returns cumulative count for a specific device
* GET action: /api/v1/device/most_recent_reading, params: id as string, returns the last reading based on its timestamp value
* GET action: /api/v1/device/all_data, not require params, allows to check all current devices readings loading on memory


* We can improve de api documentation using swager, it's very useful
* We can Add more specs for the reading library and more cases and scenarios
* We can add rubocop to improve the ruby style