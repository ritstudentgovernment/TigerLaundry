json.array!(@facilities) do |facility|
  json.extract! facility, :washers, :driers, :name
  json.url facility_url(facility, format: :json)
end
