
require 'fileutils'

namespace :vendor do
  desc 'Vendorize terminal-notifier'
  task :terminal_notifier do
    url = 'https://github.com/alloy/terminal-notifier/releases/download/1.5.0/terminal-notifier-1.5.0.zip'

    Dir.chdir('vendor') do
      Dir['*'].each do |file|
        FileUtils.remove_entry_secure(file, true)
      end

      zip_filename = 'terminal-notifier.zip'
      sh('curl', '--location', '--output', zip_filename, url)
      sh('unzip', zip_filename)
    end
  end
end
