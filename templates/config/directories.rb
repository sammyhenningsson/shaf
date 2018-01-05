require 'config/constants'

$:.unshift APP_DIR

def sort_files(files)
  files.sort_by do |file|
    case file
    when /\Alib/
      0
    when /\Ahelpers/
      1
    when /\Amodels/
      2
    when /\Acontrollers/
      3
    when /\Apolicies/
      4
    else
      5
    end
  end
end

Dir.chdir(APP_DIR) do
  files = Dir[File.join('**', '*.rb')]
  sort_files(files).each do |file|
    # load all files with .rb extension in subfolders of app
    $logger&.debug "Require file: #{file}"
    require file
  end
end
