class CreateSlalomResources < ActiveRecord::Migration
  def change
    create_table :slalom_resources do |t|
      t.string :name
      t.string :email
      t.integer :hourly_rate
      
      t.timestamps null: false
    end
  end
end
