# joyce


* [Homepage](https://rubygems.org/gems/joyce)
* [Documentation](http://rubydoc.info/gems/joyce/frames)
* [Email](mailto:jweissman1986 at gmail.com)

[![Code Climate GPA](https://codeclimate.com/github//joyce/badges/gpa.svg)](https://codeclimate.com/github//joyce)

## Description

Joyce is a multiplayer game server framework built on top of Metacosm

## What is the big idea?

The idea is to build 'isomorphic' Ruby games: to target both a Gosu game client as well as a game server
running in the cloud. Both are running the same code, but the responsibilities are split: 

  - The game server runs game business logic, and publishes events that the clients consume to hydrate their local views
  - Clients publish commands the the server validates and handles, updating game state and generating events

One upshot of this is that all game processing is kept on the server, and clients are doing nothing but
rendering views and when necessary figuring out what commands to publish (when the user interacts).

## Features

## Examples

    require 'joyce'

    module Example
      class Player < Joyce::Model
        attr_accessor :name
      end

      # window is a gosu::window
      class PlayerView < Metacosm::View
        attr_accessor :player_id, :name, :player_list
        def show(window:, player_list:)
          window.ui_font.draw(100,100,"Hello, #{name}")
          window.ui_font.draw(100,150, "Player list: #{player_list}")
        end
      end 

      class Session < Joyce::Model
        has_one :player
        has_one :game

        def tick
        end
      end
 
      class Game < Joyce::Model
        has_many :sessions

        def has_room_for_new_players?
          sessions.count < 3
        end

        def tick(step)
          sessions.each(&:tick)
        end

        def admit_player(player_id:)
          sessions.create(player_id: player_id)
          emit(PlayerAdmittedEvent.create(game_id: self.id, player_id: player.id, current_player_list: ))
        end

        private
        def current_player_list
          Session.pluck(:player).map(&:name)
        end
      end

      class App < Joyce::App
        def launch
          engine.bootstrap

          # only listen to events that could update my view...?
          engine.exclude_events(if: criteria(:player_id) != player_id)

          engine.fire(CreatePlayerCommand.create(player_id: player_id))
          engine.fire(AdmitPlayerToGame.create(player_id: player_id))
        end

        def show
          player_view = PlayerView.find(player_id: player_id)
          player_view.render(view.window)
        end
       
        private
        def player_id
          @player_id ||= SecureRandom.uuid
        end
      end

      class CreatePlayerCommand < Metacosm::Command
        attr_accessor :player_id
      end

      class CreatePlayerCommandHandler
        def handle(player_id:)
          player = Player.create(id: player_id)
        end
      end

      class AdmitPlayerToGameCommand < Metacosm::Command
        attr_accessor :player_id #, :game_id
      end

      class AdmitPlayerToGameCommandHandler
        def handle(player_id:)
          admit_player_to_game(player_id: player_id)
        end

        def admit_player_to_game(player_id:)
          # try to find a game
          game = Game.detect(&:has_room_for_new_players?) || Game.create
          game.admit_player(player_id: player_id)
        end

        def any_available_games?
          Game.any?(&:has_room_for_new_players?)
        end
      end

      class PlayerAdmittedEvent
        attr_accessor :game_id, :player_id, :current_player_list
      end

      class PlayerAdmittedEventListener
        def receive(game_id:, player_id:, current_player_list:)
          player_view = PlayerView.find_by(player_id: player_id)
          player_view.update(player_list: current_player_list)
        end
      end

      class Server < Joyce::Server
        def boot
          engine.bootstrap
          @step_count = 0 
        end

        def tick
          @step_count = @step_count + 1
          Game.all.map(&:tick)
        end
      end
    end
    
## Requirements

## Install

    $ gem install joyce

## Synopsis

    $ joyce

## Copyright

Copyright (c) 2016 Joseph Weissman

See {file:LICENSE.txt} for details.
