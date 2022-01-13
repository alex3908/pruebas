# frozen_string_literal: true

json.client_user_id @client_user.id
json.user_id @client_user.user.id
json.user_name @client_user.user.label_with_email
json.concept_id @client_user.client_user_concept.id
json.concept @client_user.client_user_concept.name
