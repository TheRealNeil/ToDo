class CreateItems < ActiveRecord::Migration[6.0]
  def change
    create_table :items do |t|
      t.belongs_to :list, null: false, foreign_key: true
      t.integer :position
      t.string :name
      t.text :description
      t.timestamp :completed_at

      t.timestamps
    end
  end
end
