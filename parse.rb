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
      location_long: row['long'],
      tags: %w{adidas nguyen_quang_minh wtf wth hihihehehha heihi}
  }
  response = HTTParty.post('http://localhost:3000/api/v1/posts.json?user_token=mimx7PX7tY1mQkKKTnph',body: body)
  puts body.inspect
  puts response
end
