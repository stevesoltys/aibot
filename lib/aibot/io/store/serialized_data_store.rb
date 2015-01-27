module AIBot
  class SerializedDataStore < DataStore
    ##
    # Loads the data for this store, given the file path.
    def load(params)
      File.open(params[:file], 'r') do |file|
        if file
          @data = Marshal.load(file)
        else
          raise 'Could not load data store file!'
        end
      end
    end

    ##
    # Serializes the data for this store and saves it to the given file.
    def save(params)
      File.open(params[:file], 'w') do |file|
        Marshal.dump(data, file)
      end
    end
  end
end