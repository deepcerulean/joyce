module Joyce
  class Application
    DEFAULT_WIDTH = 1920
    DEFAULT_HEIGHT = 1080

    def initialize(headless: false)
      @headless = headless
    end

    def setup(*)
      # ...
    end

    def tick
      # ...
    end

    def click
      # ...
    end

    def launch(*setup_args)
      sim.conduct!
      setup(*setup_args)
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
      @simulation ||= self.class.simulation_class.current # RemoteSim.current
    end

    def self.simulation_class
      if connect_immediately?
        RemoteSim
      else
        Metacosm::Simulation
      end
    end

    def self.connect_immediately?
      false
    end

    def view
      @view ||= construct_view
    end

    def window
      @window ||= @headless ? NullWindow.new(self) : ApplicationWindow.new(self, width: width, height: height)
    end

    def width
      DEFAULT_WIDTH
    end

    def height
      DEFAULT_HEIGHT
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

      def kickstart!(headless: false, setup: {})
        app = new(headless: headless)
        app.launch(setup)
        app
      end
    end
  end
end
