module AresMUSH
  module WOD20Skills

    def self.find_ability(char, ability_name)
      ability_name = ability_name.titlecase
      ability_type = WOD20Skills.get_ability_type(ability_name)
      case ability_type
      when :attribute
        char.wod20_attributes.find(name: ability_name).first
      when :action
        char.wod20_action_skills.find(name: ability_name).first
      when :background
        char.wod20_background_skills.find(name: ability_name).first
      when :advantage
        char.wod20_advantages.find(name: ability_name).first
      when :language
        char.wod20_languages.find(name: ability_name).first
      else
        nil
      end
    end

    def self.get_linked_attr(ability_name)
      case WOD20Skills.get_ability_type(ability_name)
      when :action
        config = WOD20Skills.action_skill_config(ability_name)
        return config["linked_attr"]
      when :attribute
        return nil
      else
        return Global.read_config("wod20skills", "default_linked_attr")
      end
    end

    def self.skills_census(skill_type)
      skills = {}
      Chargen.approved_chars.each do |c|

        if (skill_type == "Action")
          c.wod20_action_skills.each do |a|
            add_to_hash(skills, c, a)
          end

        elsif (skill_type == "Background")
          c.wod20_background_skills.each do |a|
            add_to_hash(skills, c, a)
          end

        elsif (skill_type == "Language")
          c.wod20_languages.each do |a|
            add_to_hash(skills, c, a)
          end

        elsif (skill_type == "Advantage")
          c.wod20_advantages.each do |a|
            add_to_hash(skills, c, a)
          end

        else
          raise "Invalid skill type selected for skill census: #{skill_type}"
        end
      end
      skills = skills.select { |name, people| people.count > 2 }
      skills = skills.sort_by { |name, people| [0-people.count, name] }
      skills
    end
  end
end
