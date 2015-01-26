module AIBot
  class SerializeDataStore < DataStore
    ##
    # Loads the data from this store, given the
    # file path.
    def load(params)
      file = File.open(params[:file])
      if file
        @data = Marshal.load(file)
        file.close
      else
        raise 'Could not load data store file!'
      end
    end

    ##
    # Serializes the data for this store and saves
    # it to the given file.
    def save(params)
      file = File.open(params[:file])
      Marshal.dump(data, file)
      file.close
    end
  end
end