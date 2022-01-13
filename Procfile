release: rails db:migrate && rails db:seed:permissions && rails db:seed:settings
web: bundle exec puma -C config/puma.rb
worker: QUEUES=default,low_priority bundle exec rails jobs:work
urgentworker: QUEUE=high_priority,mailers bundle exec rake jobs:work
