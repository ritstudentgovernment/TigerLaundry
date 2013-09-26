class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.integer :washers
      t.integer :driers
      t.references :facility, index: true

      t.timestamps
    end
  end
end
