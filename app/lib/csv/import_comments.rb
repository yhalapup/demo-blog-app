require "activerecord-import"
require "smarter_csv"
require "csv"

class Csv::ImportComments
  BATCH_SIZE = 50

  def execute(filename)
    ActiveRecord::Base.transaction do
      create_users(filename:)
      import_comments(filename:)
    end
  end

  private

  def posts_info
    Post.pluck(:id, :slug).map { |el| { id: el[0], slug: el[1] } }
  end

  def create_users(filename:, options: { chunk_size: BATCH_SIZE })
    SmarterCSV.process(filename, options) do |chunk|
      users_info = chunk.map { |element| { name: element[:user_name], email: element[:user_email] } }
      User.insert_all(users_info, unique_by: :email)
    end
  end

  def import_comments(filename:, options: { chunk_size: BATCH_SIZE })
    SmarterCSV.process(filename, options) do |chunk|
      data = add_user_ids(chunk)
      data = add_post_ids(data)

      create_comments(data)
    end
  end

  def add_user_ids(data)
    user_emails = data.pluck(:user_email)
    user_ids = User.where(email: user_emails).pluck(:id).inject([]) do |array, item|
      array << { user_id: item }
    end
    data.zip(user_ids).map { |first, second| first.merge(second) }
  end

  def add_post_ids(data)
    post_slugs = data.pluck(:post_slug)
    post_ids = post_slugs.inject([]) do |array, item|
      post_id = posts_info.find { |element| element[:slug] == item }[:id]
      array << { post_id: }
    end
    data.zip(post_ids).map { |first, second| first.merge(second) }
  end

  def create_comments(data)
    columns = %i[content post_id user_id]
    result = Comment.import columns, data, validate: true, track_validation_failures: true
    result.failed_instances.map do |element|
      custom_logger.info("Failed to create instance of Comment #{element[1].inspect}, #{element[1].errors.full_messages}")
    end
    []
  end

  def custom_logger
    @custom_logger ||= Csv::Logger.new
  end
end
