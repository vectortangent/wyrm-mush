module AresMUSH
  module WOD20Skills
    module AbilityPointCounter
      def self.total_points(char)
        return self.points_on_attrs(char) + self.points_on_action(char) +
           self.points_on_background(char) + self.points_on_language(char) +
           self.points_on_specialties(char) + self.points_on_advantages(char)
      end

      def self.points_on_attrs(char)
        char.wod20_attributes.inject(0) { |count, a| count + (a.rating > 2 ? (a.rating - 2) * 2 : 0) }
      end

      def self.points_on_action(char)
        char.wod20_action_skills.inject(0) { |count, a| count + (a.rating > 1 ? a.rating - 1 : 0) }
      end

      def self.points_on_specialties(char)
        char.wod20_action_skills.inject(0) { |count, a| count +
            (a.specialties.count > 1 ? a.specialties.count - 1 : 0) }
      end

      def self.points_on_background(char)
        free = Global.read_config("wod20skills", "free_backgrounds")
        count = char.wod20_background_skills.inject(0) { |count, a| count + a.rating }
        count > free ? count - free : 0
      end

      def self.points_on_language(char)
        free = Global.read_config("wod20skills", "free_languages")
        count = char.wod20_languages.inject(0) { |count, a| count + a.rating }
        count > free ? count - free : 0
      end

      def self.points_on_advantages(char)
        cost = Global.read_config("wod20skills", "advantages_cost")
        char.wod20_advantages.inject(0) { |count, a| count + (a.rating * cost) }
      end

    end
  end
end
