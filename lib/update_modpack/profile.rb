# frozen_string_literal: true

require_relative "config"

module UpdateModpack
  class Profile
    attr_reader :name, :dir

    def initialize(name)
      @name = name
      @dir = File.join(PROFILES_DIR, name)
    end
  end
end
