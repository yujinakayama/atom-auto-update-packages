
require 'fileutils'

desc 'Compile all CoffeeScript files'
task :compile do
  puts 'Compiling all CoffeeScript files...'
  system('coffee -o tmp -c lib spec') || fail
  puts 'Done.'
end

desc 'Run package specs'
task :spec do
  puts 'Running package specs...'
  system('apm test') || fail
end

desc 'Run CoffeeLint'
task :lint do
  puts 'Running CoffeeLint...'
  system('coffeelint lib spec') || fail
end

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

namespace :travis do
  task :prepare do
    sh 'npm install --global coffee-script coffeelint'
  end

  task :spec do
    sh 'curl -s https://raw.githubusercontent.com/atom/ci/master/build-package.sh | sh'
  end
end

task default: [:compile, :spec, :lint]
task travis: ['travis:prepare', :compile, 'travis:spec', :lint]
