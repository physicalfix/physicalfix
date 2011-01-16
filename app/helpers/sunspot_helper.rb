require 'rubygems'
require 'sunspot'

module SunspotHelper

  class InstanceAdapter < Sunspot::Adapters::InstanceAdapter
    def id
      @instance.id.to_s 
    end
  end

  class DataAccessor < Sunspot::Adapters::DataAccessor
    def load( id )
      Food.find(id)
    end

    def load_all( ids )
      ids.map { |id| Food.find(id) }
    end
  end

end