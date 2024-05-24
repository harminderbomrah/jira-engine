class CreateFieldMappings < ActiveRecord::Migration[7.1]
  def change
    create_table :field_mappings do |t|
      t.json :mapping, null: false, default: {}
      t.references :project, null: false, foreign_key: true
      t.timestamps
    end
  end
end
