require_relative 'models/game'
require_relative 'models/player'

module Example
  class SampleAppView < Joyce::ApplicationView
    def render
      game_view.render(window, font)
    end

    def game_view
      GameView.find_by active_player_id: application.player_id
    end
  end

  class SampleServer < Joyce::Server
    def setup
      # p [ :sample_server_setup ]
      Game.create
    end

    def tick
      # p [ :sample_server_tick ]
      Game.all.each(&:iterate!)
    end
  end

  class Application < Joyce::Application
    viewed_with Example::SampleAppView

    def setup
      p [ :sample_app_setup ]
      GameView.create(active_player_id: player_id)
      sim.params[:active_player_id] = player_id
    end

    def tick
      @ticks ||= 0
      @ticks += 1
      # p [ :sample_app_tick ]
      if (@ticks % 30 == 0)
        fire(PingCommand.create(player_id: player_id, player_name: player_name))
      end
    end

    def player_id
      @player_id ||= SecureRandom.uuid
    end

    def player_name
      @player_name ||= %w[ Alice Bob Cardiff Danielle Echo Fargo ].sample
    end
  end

  class BulletPointAtom
    def render(color: 0xf0f0f0f0, location:,size: 10,window:)
      x,y = location
      window.draw_quad(x,y,color,
                       x,y+size,color,
                       x+size,y,color,
                       x+size,y+size,color)
    end
  end

  class TextBoxAtom
    def render(message:, location:, font:)
      x,y = *location
      font.draw(message, x, y, 1)
    end
  end

  class ListMolecule
    def render(title: '', elements:, location:, font:, window:)
      x0,y0 = location
      font.draw(title, x0, y0, 1)
      elements.each_with_index do |element, index|
        x, y = x0, y0 + ((index+1)*20)

        bullet_point = BulletPointAtom.new
        bullet_point.render(location: [x-10,y], window: window)

        text_box = TextBoxAtom.new
        text_box.render(message: element, location: [x,y], font: font)
      end
    end
  end

  class PlayerView < Metacosm::View
    belongs_to :game_view
    attr_accessor :name, :joined_at, :player_id
  end

  class GameView < Metacosm::View
    has_many :player_views

    attr_accessor :active_player_id, :game_id
    # attr_accessor :player_names

    def render(window, font)
      # p [ :render_game_view, pinged_at: pinged_at ]
      window.draw_quad(10,10, 0xf0f0f0f0,
                       10,20, 0xf0f0f0f0,
                       20,10, 0xf0f0f0f0,
                       20,20, 0xf0f0f0f0)

      if player_names && player_names.any?
        ListMolecule.new.render(
          title: "Connected Users:",
          elements: player_names,
          location: [40,40],
          font: font,
          window: window
        )
      end
    end

    private
    def player_names
      self.player_views.map { |p| "#{p.name} (#{time_ago_in_words(p.joined_at)})" } #(&:name)
    end
  end

  class PingCommand < Metacosm::Command
    attr_accessor :player_id, :player_name
  end

  class PingCommandHandler
    def handle(player_id:, player_name:)
      p [ :ping, from_player: player_id ]
      game = Game.find_by(players: { id: player_id })
      if game.nil?
        # we could try to create a new game for the player?
        # or add them to an existing one?
        p [ :no_game_yet! ]

        game = Game.first || Game.create
        game.admit_player(player_id: player_id, player_name: player_name)
      end

      game.ping(player_id: player_id)
    end
  end

  #
  # class GameController
  #   def ping(player_id:, player_name:)
  #     game = Game.find_by ... 
  #   end
  # end
  # 

  class ApplicationEventListener < Metacosm::EventListener
    def game_view
      GameView.find_by(active_player_id: active_player_id)
    end

    def active_player_id
      self.simulation.params[:active_player_id]
    end
  end

  class PlayerAdmittedEvent < Metacosm::Event
    attr_accessor :player_id, :player_name, :connected_player_list
  end

  class PlayerAdmittedEventListener < ApplicationEventListener
    def receive(player_id:, player_name:, connected_player_list:)
      p [ :player_admitted_event_listener ]
      if game_view
        # game_view.create_player_view(player_id: player_id, name: player_name, joined_at: Time.now)
        # go through connected player list and make views...
        connected_player_list.each do |id:, name:, joined_at:|
          player_view = game_view.player_views.where(player_id: id).first_or_create
          player_view.update(name: name, joined_at: joined_at)
        end
      end
    end
  end

  class PlayerDroppedEvent < Metacosm::Event
    attr_accessor :player_id, :connected_player_list
  end

  class PlayerDroppedEventListener < ApplicationEventListener
    def receive(player_id:, connected_player_list:)
      p [ :player_dropped_event_listener! ]
      if game_view
        game_view.player_views.map(&:destroy)
        connected_player_list.each do |id:, name:, joined_at:|
          player_view = game_view.player_views.where(player_id: id).first_or_create
          player_view.update(name: name, joined_at: joined_at)
        end
      end
    end
  end


  # class PlayerSaga < Metacosm::Saga
  #   def player_dropped(player_id:, connected_player_list:)
  #   end
  #   def player_admitted(player_id:, player_name:, connected_player_list:)
  #   end
  # end
end
