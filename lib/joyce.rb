require 'gosu'
require 'redis' # TODO move require to mc/remote_sim?
require 'metacosm'
require 'metacosm/remote_simulation'

require 'joyce/version'
require 'joyce/application'

module Joyce
  EVENT_STREAM  = :joyce_event_stream
  COMMAND_QUEUE = :joyce_command_queue

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
  end

  class ApplicationWindow < Gosu::Window
    attr_accessor :width, :height
    attr_reader :app

    def initialize(app, width: 800, height: 600)
      @app = app
      self.width  = width
      self.height = height

      super(self.width, self.height)
    end

    def draw
      app.view.render
    end

    def update
      app.tick
    end
  end

  class NullWindow
    attr_reader :app
    def initialize(app, width: 800, height: 600)
      # p [ :created_null_window, provided_dimensions: [ width, height ] ]
      @app = app
    end

    def show
      app.tick
      false
    end

    def draw_quad(*)
      # p [ :null_window, :draw_quad ]
      self
    end
  end

  class Server
    def setup
      # p [ :server_setup ]
    end

    def boot
      sim.on_event(publish_to: EVENT_STREAM)
      @cmd_thread = sim.subscribe_for_commands(channel: COMMAND_QUEUE)
      setup
      sim.conduct!
      drive!
      # cmd_thread.join
    end

    def join
      @cmd_thread.join
    end

    def tick
      # p [ :server_tick ]
    end

    def drive!
      @driving = true
      Thread.new do
        while @driving
          tick
          sleep 0.05
        end
      end
    end

    def halt!
      @driving = false
    end

    def sim
      @simulation ||= Metacosm::Simulation.current
    end

    def received_commands
      sim.received_commands
    end

    class << self
      def kickstart!
        server = new
        server.boot
        server
      end
    end
  end

  class RemoteSim < Metacosm::RemoteSimulation
    def initialize
      super(COMMAND_QUEUE, EVENT_STREAM)
    end

    def redis_connection
      ::Redis.new
    end
  end
end
