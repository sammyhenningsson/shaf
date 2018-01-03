Dir[File.join(__dir__, 'tasks', '*.rb')].each do |task|
  require task
end

