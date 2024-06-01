require "faker"

# Create Users
users = Array.new(10) do
  User.create(
    name: Faker::Name.name,
    email: Faker::Internet.email
  )
end

# Create Categories
categories = %w[Technology Lifestyle Education Health Travel].map do |category_name|
  Category.create(name: category_name)
end

# Create Posts
Array.new(100) do
  Post.create(
    title: Faker::Lorem.sentence(word_count: 3),
    content: Faker::Lorem.paragraph(sentence_count: 10),
    user: users.sample,
    category: categories.sample
  )
end
