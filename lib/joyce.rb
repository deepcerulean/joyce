require 'pry'
require 'gosu'
# require 'metacosm'
require 'joyce/version'
require 'joyce/application'

module Joyce
  class ApplicationView
    def initialize(application)
      @application ||= application
    end

    def render
      # ...
    end

    protected
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
    def initialize(app, width: 800, height: 600)
      p [ :created_null_window, provided_dimensions: [ width, height ] ]
    end

    def show
      false
    end

    def draw_quad(*)
      p [ :null_window, :draw_quad ]
      self
    end
  end

  class Server
    def initialize
      @step_count = 0
    end

    def boot
    end

    def tick
      @step_count += 1
      Game.all.step(&:tick)
    end

    def self.kickstart!
      Server.new.boot
    end
  end
end
