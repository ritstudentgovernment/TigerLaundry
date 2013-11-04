submissions_arr = []
@submissions.each do |submission|
  submissions_arr << [submission.created_at.iso8601.to_s, submission.washers, submission.driers]
end
json.array! submissions_arr
