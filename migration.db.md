rails g migration CreateReceivables amount_cents:integer due_date:date


bin/rails db:migrate
RAILS_ENV=test bin/rails db:migrate