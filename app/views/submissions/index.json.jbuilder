json.array!(@submissions) do |submission|
  json.extract! submission, :washers, :driers, :facility_id
  json.url facility_submission_url(@facility, submission, format: :json)
end
