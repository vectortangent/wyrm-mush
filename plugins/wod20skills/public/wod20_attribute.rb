module AresMUSH
  class WOD20Attribute < Ohm::Model
    include ObjectModel
    include LearnableAbility

    reference :character, "AresMUSH::Character"
    attribute :name
    attribute :rating, :type => DataType::Integer, :default => 0

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
      when 4
        return "%xg@%xy@%xr@%xb@%xn"
      end
    end

    def rating_name
      case rating
      when 0
        return ""
      when 1
        return t('wod20skills.poor_rating')
      when 2
        return t('wod20skills.average_rating')
      when 3
        return t('wod20skills.good_rating')
      when 4
        return t('wod20skills.exceptional_rating')
      end
    end
  end
end
