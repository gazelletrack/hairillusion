require 'sidekiq'
require 'sidekiq/web'

Sidekiq.configure_server do |config|
  config.redis = { :url => ENV['REDIS_URL'] }
end

Sidekiq.configure_client do |config|
  config.redis = { :size => 1 }
end

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == 'admin' && password == 'h41r1llus10n'
end 
