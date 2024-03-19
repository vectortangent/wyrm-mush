module AresMUSH
  class Character
    attribute :wod20_xp, :type => DataType::Integer, :default => 0
    attribute :wod20_luck, :type => DataType::Float, :default => 1
    attribute :wod20_cookie_archive, :type => DataType::Integer, :default => 0
    attribute :wod20_scene_luck, :type => DataType::Hash, :default => {}

    collection :wod20_attributes, "AresMUSH::WOD20Attribute"
    collection :wod20_action_skills, "AresMUSH::WOD20ActionSkill"
    collection :wod20_background_skills, "AresMUSH::WOD20BackgroundSkill"
    collection :wod20_languages, "AresMUSH::WOD20Language"
    collection :wod20_advantages, "AresMUSH::WOD20Advantage"
    collection :wod20_gifts, "AresMUSH::WOD20Gift"
    collection :wod20_merits, "AresMUSH::WOD20Merit"
    collection :wod20_pools, "AresMUSH::WOD20Pool"

    before_delete :delete_abilities

    def delete_abilities
      [ self.wod20_attributes, self.wod20_action_skills, self.wod20_background_skills, self.wod20_languages, self.wod20_advantages].each do |list|
        list.each do |a|
          a.delete
        end
      end
    end

    def luck
      self.wod20_luck
    end

    def xp
      self.wod20_xp
    end

    def award_luck(amount)
      WOD20Skills.modify_luck(self, amount)
    end

    def spend_luck(amount)
      WOD20Skills.modify_luck(self, -amount)
    end

    def award_xp(amount)
      WOD20Skills.modify_xp(self, amount)
    end

    def spend_xp(amount)
      WOD20Skills.modify_xp(self, -amount)
    end

    def reset_xp
      self.update(wod20_xp: 0)
    end

    def roll_ability(ability, mod = 0)
      WOD20Skills.one_shot_roll(self, WOD20Skills::RollParams.new(ability, mod))
    end
  end
end
