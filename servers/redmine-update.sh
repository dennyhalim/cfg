RAILS_ENV=production bundle exec rake generate_secret_token db:migrate redmine:plugins:migrate tmp:cache:clear tmp:sessions:clear
