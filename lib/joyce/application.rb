module Joyce
  class Application
    def initialize(headless: false)
      @headless = headless
    end

    def launch
      window.show
      self
    end

    def tick
      p [ :app_tick ]
    end

    def view
      @view ||= construct_view
    end

    def window
      @window ||= @headless ? NullWindow.new(self) : ApplicationWindow.new(self)
    end

    private
    def construct_view
      self.class.view_class.new(self)
    end

    class << self
      attr_reader :view_class
      def viewed_with(view_class)
        @view_class ||= view_class
        self
      end

      def kickstart!(headless: false)
        app = new(headless: headless)
        app.launch
        app
      end
    end
  end
end
