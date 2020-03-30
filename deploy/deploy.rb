#!/usr/bin/env ruby

require 'erb'
require 'tmpdir'

REQUIRED_RUBY_VERSION='2.6.5'
APP_DIR = File.expand_path('~/automatic-deployment/payments-app')
SERVICE_NAME = 'application'

def main
  install_ruby
  patch_path
  install_required_gems(APP_DIR)
  setup_systemd_service(APP_DIR)
  enable_systemd_service
end

def install_ruby
  current_dir = Dir.pwd
  Dir.mktmpdir do |directory|
    Dir.chdir(directory)
    checked_run('wget', '-O', 'ruby-install-0.7.0.tar.gz', 'https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz')
    checked_run('tar', '-xzvf', 'ruby-install-0.7.0.tar.gz')
    Dir.chdir('ruby-install-0.7.0')
    checked_run('sudo', 'make', 'install')
  end
  Dir.chdir(current_dir)
  checked_run('ruby-install', '-L')
  checked_run('ruby-install', '--jobs=4', 'ruby', REQUIRED_RUBY_VERSION)
end

def checked_run(*args)
  command = args.join(' ')
  puts "Running #{command}"
  result = system(*args)
  unless result
    puts "Command #{command} finished with error"
    exit(1)
  end
end

def patch_path
  ENV['PATH'] = ruby_installation_path + ':' + ENV['PATH']
end

def ruby_installation_path
  File.expand_path("~/.rubies/ruby-#{REQUIRED_RUBY_VERSION}/bin") 
end

def install_required_gems(application_directory)
  Dir.chdir(application_directory)
  checked_run('bundle', 'install')
end

def setup_systemd_service(application_directory)
  template = File.read(File.expand_path('application.service.erb', __dir__))
  path = ENV['PATH']
  bundle_path = File.join(ruby_installation_path, 'bundle')
  clojure = binding
  baked_template = ERB.new(template).result(clojure)

  file_path = File.join(__dir__, "#{SERVICE_NAME}.service")
  File.write(file_path, baked_template)

  checked_run('sudo', 'mv', file_path, '/etc/systemd/system')
  checked_run('sudo', 'systemctl', 'daemon-reload')
end

def enable_systemd_service
  checked_run('sudo', 'systemctl', 'enable', SERVICE_NAME)
end

if __FILE__ == $0
  main
end

