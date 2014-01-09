class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :spree_documents do |t|
      t.string :name
      t.text :description
      t.references :source, polymorphic: true
      t.string :document_file_name
      t.string :document_content_type
      t.integer :document_file_size

      t.timestamps
    end
  end
end
