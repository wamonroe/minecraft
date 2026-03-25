# frozen_string_literal: true

module UpdateModpack
  class Modpack
    attr_reader :name, :path

    def initialize(path)
      @path = path
      @name = File.basename(path)
    end
  end
end
