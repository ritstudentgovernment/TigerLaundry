json.array!(@submissions) do |submission|
  json.extract! submission, :washers, :driers, :facility_id
  json.url submission_url(submission, format: :json)
end
