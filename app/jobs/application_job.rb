class ApplicationJob < ActiveJob::Base
  queue_as :default

  def perform
  end
end
