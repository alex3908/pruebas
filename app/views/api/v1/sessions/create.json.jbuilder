# frozen_string_literal: true

json.user do
  json.first_name @user.first_name
  json.last_name @user.last_name
  json.email @user.email
end
json.authentication_token do
  json.token @authentication_token
  json.exp_time @exp_time
end
