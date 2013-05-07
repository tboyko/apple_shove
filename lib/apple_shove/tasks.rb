require 'rake'

include Rake::DSL

namespace :apple_shove do
    
  desc 'Display service statistics every second'
  task :stats do
    require 'apple_shove'

    begin
      puts AppleShove.stats
      sleep 1
    end while true
  end

  desc 'Start the daemon in the foreground'
  task :run do
    exec "ruby #{path_to_daemon} run#{argument_string}"
  end

  desc 'Start the daemon'
  task :start do
    exec "ruby #{path_to_daemon} start#{argument_string}"
  end

  desc 'Stop the daemon'
  task :stop do
    exec "ruby #{path_to_daemon} stop#{argument_string}"
  end

  desc 'Restart the daemon'
  task :restart do
    exec "ruby #{path_to_daemon} restart#{argument_string}"
  end

  desc 'Show the status (PID) of the daemon'
  task :status do
    exec "ruby #{path_to_daemon} status"
  end

  private 
  
  def path_to_daemon
    File.join(File.dirname(__FILE__), '..', '..', 'script', 'daemon')
  end

  def argument_string
    watched_args = ['log_dir', 'pid_dir', 'connection_limit']
    arg_str = watched_args.collect { |a| ENV[a] ? "--#{a}=#{ENV[a]}" : nil }.compact.join(' ')
    
    arg_str.empty? ? nil : " -- #{arg_str}"
  end


end