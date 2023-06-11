class FocevJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "from job"
    File.open("out.txt", "w") do |f|
      f.write("hello")
    end
  end
end
