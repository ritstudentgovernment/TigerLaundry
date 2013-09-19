class AddFacilityIdToSubmission < ActiveRecord::Migration
  def change
    add_column :submissions, :facility_id, :reference
  end
end
