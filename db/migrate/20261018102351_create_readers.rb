class CreateReaders < ActiveRecord::Migration[8.1]
  def change
    create_table :readers do |t|
      t.string :library_card_number, null: false, index: { unique: true }
      t.string :name, null: false, index: true
      t.string :email, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
