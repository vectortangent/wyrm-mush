module AresMUSH
  class WOD20Pool < Ohm::Model
    include ObjectModel
    include LearnableAbility

    reference :character, "AresMUSH::Character"
    attribute :name
    attribute :rating, :type => DataType::Integer, :default => 0
    attribute :temporary, :type => DataType::Integer, :default => 0

    index :name

    def print_rating
      case rating
      when 0
          return ""
      when 1
        return "%xg@%xn"
      when 2
        return "%xg@%xy@%xn"
      when 3
        return "%xg@%xy@%xr@%xn"
      end
    end

    def rating_name
      case rating
      when 0
        return t('wod20skills.everyman_rating')
      when 1
        return t('wod20skills.fair_rating')
      when 2
        return t('wod20skills.good_rating')
      when 3
        return t('wod20skills.exceptional_rating')
      end
    end
  end
end
