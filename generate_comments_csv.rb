# generate_comments_csv.rb

require "csv"
require "faker"
require_relative "config/environment"

# Fetch all post slugs from the database
post_slugs = Post.pluck(:slug)

# Number of comments to generate
num_comments = 10_000

# Array to hold comment data
comments_data = []

# Generate random comments
num_comments.times do
  content = Faker::Lorem.sentence(word_count: 10)
  post_slug = post_slugs.sample
  user_name = Faker::Name.name
  user_email = Faker::Internet.email

  comments_data << [post_slug, user_name, user_email, content]
end

# Define CSV file path
csv_file_path = "comments.csv"

# Write comments to CSV
CSV.open(csv_file_path, "wb") do |csv|
  csv << ["Post Slug", "User Name", "User Email", "Content"] # CSV header
  comments_data.each do |comment|
    csv << comment
  end
end

puts "CSV file generated at #{csv_file_path}"
