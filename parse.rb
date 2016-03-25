require 'httparty'
require 'byebug'
CSV.foreach("listdeal.csv", headers: true) do |row|
  puts "==============="
  puts "Ready to send"
  puts "==============="
  body =  {
      description: row['description'],
      picture_url: row['img'],
      post_type: 'crawl',
      crawl_user_name: row['name'],
      location_lat: row['lat'],
      location_long: row['long']
  }
  response = HTTParty.post('https://solomo-api.herokuapp.com/api/v1/posts.json?user_token=jT9jkh4rMrUReQCsweHY',body: body)
  puts body.inspect
  puts response
end
