module AresMUSH
  class WOD20Fetish < Ohm::Model
    include ObjectModel
    include LearnableAbility

    reference :character, "AresMUSH::Character"
    attribute :name
    attribute :level, :type => DataType::Integer, :default => 0

    index :name

  end
end
