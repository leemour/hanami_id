# frozen_string_literal: true

module HanamiId
  class Path
    def initialize(path)
      @path = path
    end

    def join(*args)
      Path.new File.join(@path, *args)
    end

    def to_s
      @path
    end
  end
end
