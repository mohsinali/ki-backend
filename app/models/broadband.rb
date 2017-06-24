class Broadband < ApplicationRecord
  include AlgoliaSearch

  has_many :points

  algoliasearch do
    attribute :anchorname, :address, :bldgnbr, :predir, :streetname, :streettype, :suffdir, :city, :state_code, :zip5, :publicwifi, :url, :id, :_geoloc
    # attribute :_geoloc do
    #   _geoloc
    # end

    searchableAttributes ['address', 'city', 'state_code', 'anchorname']
  end

  def self.search(q)
    algolia_search(q)
  end

  def _geoloc
    { lat: latitude, lng: longitude }
  end
end
