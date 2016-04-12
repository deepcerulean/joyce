module Joyce
  class Application
    def initialize(headless: false)
      @headless = headless
    end

    def setup
      # ...
    end

    def tick
      # ...
    end

    def launch
      sim.conduct!
      setup
      window.show
      self
    end

    def fire(cmd)
      sim.fire(cmd)
    end

    def received_events
      sim.received_events
    end

    def sim
      @simulation ||= RemoteSim.current
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
