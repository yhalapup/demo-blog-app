require "activerecord-import"
require "smarter_csv"
require "csv"

namespace :import_from_csv do
  desc "imports data from csv to database"
  task comments: :environment do
    filename = ENV.fetch("FILENAME", "comments.csv")
    Csv::ImportCommentsJob.perform_now(filename)
  end
end
