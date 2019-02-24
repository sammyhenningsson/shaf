dir = File.join(Shaf::Settings.app_dir, 'helpers')
if Dir.exist? dir
  Dir.chdir(dir) do
    modules = []
    Dir[File.join('**', '*.rb')].each do |file|
      File.open(file, "r") do |f|
        f.each_line do |line|
          modules << line[%r(\A\s*module\s+(\S+)\s*\Z), 1]
        end
      end
    end
    modules.compact!
    modules.each do |mod|
      $logger&.debug "helper: #{mod}"
      BaseController.send(:class_eval, "helpers #{mod}")
    end
  end
end
