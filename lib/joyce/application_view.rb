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
      @font ||= if defined?(Gosu)
                  Gosu::Font.new(20)
                else
                  nil # NullFont?
                end
    end

    def mouse_position
      window.mouse_position
    end
  end
end
