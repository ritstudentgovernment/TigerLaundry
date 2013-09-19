class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.integer :driers
      t.integer :washers

      t.timestamps
    end
  end
end
