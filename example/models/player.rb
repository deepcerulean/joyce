module Example
  class Player < Metacosm::Model
    belongs_to :game
    attr_accessor :name, :joined_at, :pinged_at
  end
end
