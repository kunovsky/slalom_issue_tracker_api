class CreateDefectLists < ActiveRecord::Migration
  def change
    create_table :defect_lists do |t|
      t.json :data

      t.timestamps null: false
    end
  end
end
