class Csv::Logger < ActiveSupport::Logger
  def initialize
    super("log/#{Rails.env}_csv.log")
  end
end
