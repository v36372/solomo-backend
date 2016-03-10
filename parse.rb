require 'httparty'
require 'byebug'
CSV.foreach("listdeal.csv", headers: true) do |row|
  HTTParty.post('https://solomo-api.herokuapp.com/api/v1/posts.json?user_token=jT9jkh4rMrUReQCsweHY',body: {
      description: row['description'],
      picture_url: "http:#{row['img']}",
      post_type: 'crawl',
      crawl_user_name: row['name']
  })
end