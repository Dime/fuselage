# Load the template helpers
def catalog_root
  if !ENV['FUSELAGE_DIR']
    "#{root}/../"
  else
    ENV['FUSELAGE_DIR']
  end
end

load_template "#{catalog_root}/helper.rb"

template do
  log_header "Siyelo Fuselage - Rails Templates"

  app_name                = File.basename(root)
  ENV['_APP']             = app_name.gsub(/[_-]/, ' ').titleize
  ENV['_APP_SUBDOMAIN']   = app_name.gsub(/[_\s]/, '-').downcase
  ENV['_APP_DB']          = app_name.gsub(/[-\s]/, '_').downcase
  ENV['_DOMAIN']          = ENV['DOMAIN'] || 'siyelo.com'
  ENV['_APP_URL']         = "#{ENV['_APP_SUBDOMAIN']}.#{ENV['_DOMAIN']}"
  ENV['_ORG']             = ENV['ORGANIZATION'] || "Siyelo"
  ENV['_DESCR']           = ENV['DESCRIPTION'] || 'This is a cool app'
  ENV['_MYSQL_PASS']      = ENV['MYSQL_PASS'] || ask("MySQL root user password? :")
  skip_gems               = ENV['SKIP_GEMS']

  gem_source_warning

  # Enforce this good practice if you're using github.
  log_header "Get github user"
  github_user = get_github_user

  templates = %w[basic 
                  git
                  mysql
                  authlogic
                  paperclip
                  recaptcha
                  capistrano
                  haml_sass_compass_blueprint
                  formtastic 
                  cufon
                  friendly_id 
                  make_resourceful 
                  will_paginate
                  cucumber_rspec_rpec-rails_webrat 
                  machinist_forgery 
                  watchr
                  thinking-sphinx
                  tarantula
                  metric_fu 
                  passenger
                  asset_packager 
                  capistrano 
                  exception_notification
                  whenever ]

  log_header "Install List"
  templates.each { |t| puts "  #{t}" }

  templates.each do |t|
    log_header "#{t.capitalize}"
    load_sub_template t  
  end

  log_header "DB Migrate"
  %w[development test].each do |env|
    run "rake db:migrate RAILS_ENV=#{env}"
  end

  log_header "A freeze is coming!"
  rake 'rails:freeze:gems'

  log_header "Vendoring gems"
  rake "gems:unpack:dependencies"

  log_header "Git"
  load_sub_template 'git'

  unless skip_gems
    log_header "Install gems locally"
    log("  set SKIP_GEMS if you do not want to install gems via sudo")
    # Make sure all these gems are actually installed locally
    run "sudo rake gems:install"
    run "sudo rake gems:install RAILS_ENV=test"
  end
end

run_template unless ENV['TEST_MODE'] # hold off running the template whilst in unit testing mode