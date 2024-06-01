class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validate :content_does_not_contain_prohibited_keywords

  private

  def content_does_not_contain_prohibited_keywords
    prohibited_keywords = Array.new(20) { Faker::Lorem.unique.word }
    prohibited_keywords.each do |keyword|
      if content.downcase.include?(keyword)
        errors.add(:content, "contains prohibited keyword: #{keyword}")
        break
      end
    end
  end
end
