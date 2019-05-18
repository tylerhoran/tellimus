namespace :tellimus do
  desc "Install tellimus"
  task :install do
    system 'rails g tellimus:install'
  end

  desc "Install tellimus views for application-specific modification"
  task :views do
    system 'rails g tellimus:views'
  end
end

