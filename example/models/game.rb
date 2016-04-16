module Example
  class Game < Metacosm::Model
    has_many :players

    def iterate!
      # check for dropped players
      p [ :players_pinged_at, self.players.pluck(:pinged_at) ]
      players_to_drop = self.players.all.select do |player|
        player.pinged_at < 3.seconds.ago
      end

      players_to_drop.each do |player|
        p [ :dropping_player, name: player.name ]
        drop_player(player)
      end

      self
    end

    def ping(player_id:)
      player = self.players.where(id: player_id).first
      player.update(pinged_at: Time.now)
      self
    end

    def admit_player(player_name:, player_id:)
      self.players.create(
        name: player_name,
        id: player_id,
        joined_at: Time.now,
        pinged_at: Time.now
      )

      emit(
        PlayerAdmittedEvent.create(
          player_id: player_id,
          player_name: player_name,
          connected_player_list: connected_player_list,
        )
      )

      self
    end

    private
    def drop_player(player)
      lost_player_id = player.id
      player.destroy

      emit(
        PlayerDroppedEvent.create(
          player_id: lost_player_id,
          connected_player_list: connected_player_list
        )
      )
    end

    def connected_player_list
      self.players.map do |player|
        {
          id: player.id,
          name: player.name,
          joined_at: player.joined_at
        }
      end
    end
  end
end
