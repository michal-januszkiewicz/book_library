class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string :serial_number, null: false, index: { unique: true }
      t.string :title, null: false, index: true
      t.string :author, null: false, index: true

      t.timestamps
    end
  end
end
