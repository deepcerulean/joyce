module Joyce
  class ApplicationView
    attr_reader :application

    def initialize(application)
      @application ||= application
    end

    def render
      # ...
    end

    def window
      @application.window
    end

    def font
      @font ||= Gosu::Font.new(20)
    end

    def mouse_position
      window.mouse_position
    end
  end
end
