class Csv::ImportCommentsJob < ApplicationJob
  queue_as :high

  def perform(filename)
    Csv::ImportComments.new.execute(filename)
  end
end
