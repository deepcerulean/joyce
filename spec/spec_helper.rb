require 'rspec'
require 'pry'

require 'joyce/version'
require 'joyce/application'
require 'joyce'

include Joyce

module Example
  class SampleAppView < Joyce::ApplicationView
    def render
      game_view.render(window)
    end

    def game_view
      GameView.find_by player_id: application.player_id
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

  class SampleApp < Joyce::Application
    viewed_with Example::SampleAppView

    def setup
      p [ :sample_app_setup ]
      GameView.create(player_id: player_id)
    end

    def tick
      # p [ :sample_app_tick ]
    end

    def player_id
      @player_id ||= SecureRandom.uuid
    end
  end

  # example models
  class Player < Metacosm::Model
    belongs_to :game
    attr_accessor :name
  end

  class Game < Metacosm::Model
    has_many :players

    def iterate!
      # p [ :game_iterated! ]
    end

    def ping(player_id:,pinged_at:)
      # could track pings and self-destruct if there's no players left...
    end

    def admit_player(player_name:, player_id:)
      self.players.create(name: player_name, id: player_id)
      emit(
        PlayerAdmittedEvent.create(
          player_name: player_name,
          player_id: player_id,
          game_id: self.id
        )
      )
    end
  end

  class GameView < Metacosm::View
    attr_accessor :player_id, :game_id
    attr_accessor :pinged_at

    def render(window)
      # p [ :render_game_view, pinged_at: pinged_at ]
      window.draw_quad(10,10, 0xf0f0f0f0,
                       10,20, 0xf0f0f0f0,
                       20,10, 0xf0f0f0f0,
                       20,20, 0xf0f0f0f0)
    end
  end

  class PingCommand < Metacosm::Command
    attr_accessor :player_id, :player_name
  end

  class PingCommandHandler
    def handle(player_id:, player_name:)
      p [ :ping, from_player: player_id ]
      game = Game.find_by(players: { player_id: player_id })
      if game.nil?
        # we could try to create a new game for the player?
        # or add them to an existing one?
        p [ :no_game_yet! ]
        game = Game.first || Game.create
        game.admit_player(player_id: player_id, player_name: player_name)
      end

      game.ping(player_id: player_id, pinged_at: Time.now)
    end
  end

  class PlayerAdmittedEvent < Metacosm::Event
    attr_accessor :player_id, :player_name, :game_id
  end

  class PlayerAdmittedEventListener < Metacosm::EventListener
    def receive(player_id:, player_name:, game_id:)
      game_view = GameView.find_by(player_id: player_id)
      if game_view
        new_player_names = game_view.player_names + [ player_name ]
        p [ :player_admitted, new_player_names: new_player_names ]
        game_view.update(player_names: new_player_names, game_id: game_id)
      end
    end
  end
end
