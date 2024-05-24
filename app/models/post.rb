
class Post < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :comments, dependent: :destroy
  
  
  before_validation :generate_slug

  validates :slug, uniqueness: true

  def to_param
    slug
  end

  private

  def generate_slug
    base_slug = title.parameterize
    counter = 1
    unique_slug = base_slug

    while Post.exists?(slug: unique_slug)
      unique_slug = "#{base_slug}-#{counter}"
      counter += 1
    end

    self.slug = unique_slug
  end
  
  
end
