json.array!(@users) do |user|
  json.extract! user, :name, :email, :sign_in_count, :created_at, :updated_at
  json.url user_url(user, format: :json)
end
