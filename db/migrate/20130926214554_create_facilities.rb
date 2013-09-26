class CreateFacilities < ActiveRecord::Migration
  def change
    create_table :facilities do |t|
      t.integer :washers
      t.integer :driers
      t.string :name

      t.timestamps
    end
  end
end
