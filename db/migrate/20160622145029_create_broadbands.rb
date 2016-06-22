class CreateBroadbands < ActiveRecord::Migration
  def change
    create_table :broadbands, id: false do |t|
      t.string :anchorname
      t.string :address
      t.string :bldgnbr
      t.string :predir
      t.string :streetname
      t.string :streettype
      t.string :suffdir
      t.string :city
      t.string :state_code
      t.string :zip5
      t.string :latitude
      t.string :longitude
      t.string :publicwifi
      t.string :url

      t.timestamps null: false
    end
  end
end
