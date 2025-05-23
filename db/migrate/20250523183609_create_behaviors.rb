class CreateBehaviors < ActiveRecord::Migration[8.0]
  def change
    create_table :behaviors do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :behaviors, [:name, :user_id], unique: true
  end
end
