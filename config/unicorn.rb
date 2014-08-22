# https://devcenter.heroku.com/articles/rails-unicorn

run_sidekiq_in_this_thread = %w(staging production).include?(ENV['RAILS_ENV'])
# worker_processes (run_sidekiq_in_this_thread ? 2 : 3)
@sidekiq_pid = nil

worker_processes (ENV["WEB_CONCURRENCY"] || (run_sidekiq_in_this_thread ? 2 : 3)).to_i
timeout (ENV["WEB_TIMEOUT"] || 5).to_i
preload_app true

before_fork do |server, worker|
  Signal.trap "TERM" do
    puts "Unicorn master intercepting TERM and sending myself QUIT instead"
    Process.kill "QUIT", Process.pid
  end

  if defined? ActiveRecord::Base
    ActiveRecord::Base.connection.disconnect!
  end

  if run_sidekiq_in_this_thread
    @resque_pid ||= spawn("bundle exec sidekiq -c 2")
    Rails.logger.info('Spawned sidekiq #{@request_pid}')
  end
end

after_fork do |server, worker|
  Signal.trap "TERM" do
    puts "Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT"
  end

  if defined? ActiveRecord::Base
    config = ActiveRecord::Base.configurations[Rails.env] ||
      Rails.application.config.database_configuration[Rails.env]
    config["reaping_frequency"] = (ENV["DB_REAPING_FREQUENCY"] || 10).to_i
    config["pool"] = (ENV["DB_POOL"] || 2).to_i
    ActiveRecord::Base.establish_connection(config)
  end
end
