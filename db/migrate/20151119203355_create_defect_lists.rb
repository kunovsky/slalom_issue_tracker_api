class CreateDefectLists < ActiveRecord::Migration
  def change
    create_table :defect_lists do |t|

      t.timestamps null: false
    end
  end
end
