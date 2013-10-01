submissions_arr = []
@submissions.each do |submission|
  submissions_arr << [submission.created_at.to_s, submission.washers, submission.driers]
end
json.array! submissions_arr
