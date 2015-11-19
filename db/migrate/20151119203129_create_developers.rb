class CreateDevelopers < ActiveRecord::Migration
  def change
    create_table :developers do |t|
      t.string :name
      t.string :email
      t.string :hourly_rate

      t.timestamps null: false
    end
  end
end
