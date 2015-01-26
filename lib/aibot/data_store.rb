module AIBot
  class DataStore
    attr_reader :data

    def initialize
      @data = {}
    end

    def keys
      data.keys
    end

    def has?(key)
      data.include? key
    end

    def get(key)
      data[key]
    end

    def put(key, value)
      data[key] = value
    end

    def load(params=nil)
      raise 'SubclassResponsibility'
    end

    def save(params=nil)
      raise 'SubclassResponsibility'
    end
  end
end