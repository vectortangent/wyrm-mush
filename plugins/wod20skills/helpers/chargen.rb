module AresMUSH
  module WOD20Skills

    def self.set_ability(char, ability_name, rating)
      ability_name = ability_name ? ability_name.titleize : nil
      error = WOD20Skills.check_ability_name(ability_name)
      if (error)
        return error
      end

      ability_type = WOD20Skills.get_ability_type(ability_name)

      min_rating = WOD20Skills.get_min_rating(ability_type)
      ability = WOD20Skills.find_ability(char, ability_name)

      if (ability)
        ability.update(rating: rating)
      else
        case ability_type
        when :action
          ability = WOD20ActionSkill.create(character: char, name: ability_name, rating: rating)
        when :background
          ability = WOD20BackgroundSkill.create(character: char, name: ability_name, rating: rating)
        when :language
          ability = WOD20Language.create(character: char, name: ability_name, rating: rating)
        when :advantage
          ability = WOD20Advantage.create(character: char, name: ability_name, rating: rating)
        when :attribute
          ability = WOD20Attribute.create(character: char, name: ability_name, rating: rating)
        end
      end

      rating_name = ability.rating_name

      if (rating == min_rating)
        if (ability && (ability_type == :background || ability_type == :language || ability_type == :advantage))
          ability.delete
        end
      end

      return nil
    end

    # Checks to make sure an ability name doesn't have any funky characters in it.
    def self.check_ability_name(ability)
      return t('wod20skills.no_special_characters') if (ability !~ /^[\w\s]+$/)
      return nil
    end

    def self.ability_raised_text(char, ability_name)
      ability = WOD20Skills.find_ability(char, ability_name)
      if (ability)
        ability_type = WOD20Skills.get_ability_type(ability_name)
        t("wod20skills.#{ability_type}_set", :name => ability.name, :rating => ability.rating_name)
      else
        t("wod20skills.ability_removed", :name => ability_name)
      end
    end

    def self.get_min_rating(ability_type)
      case ability_type
      when :action
        if (Global.read_config('wod20skills', 'allow_incapable_action_skills'))
          min_rating = 0
        else
          min_rating = 1
        end
      when :background, :language, :advantage
        min_rating = 0
      when :attribute
        min_rating = 1
      end
      min_rating
    end

    def self.get_max_rating(ability_type)
      case ability_type
      when :action
        max_rating = Global.read_config("wod20skills", "max_skill_rating")
      when :background, :language, :advantage
        max_rating = 3
      when :attribute
        max_rating = Global.read_config("wod20skills", "max_attr_rating")
      end
    end

    def self.check_rating(ability_name, rating)
      ability_type = WOD20Skills.get_ability_type(ability_name)
      min_rating = WOD20Skills.get_min_rating(ability_type)
      max_rating = WOD20Skills.get_max_rating(ability_type)

      return t('wod20skills.max_rating_is', :rating => max_rating) if (rating > max_rating)
      return t('wod20skills.min_rating_is', :rating => min_rating) if (rating < min_rating)
      return nil
    end

    def self.reset_char(char)
      char.wod20_action_skills.each { |s| s.delete }
      char.wod20_attributes.each { |s| s.delete }
      char.wod20_background_skills.each { |s| s.delete }
      char.wod20_languages.each { |s| s.delete }
      char.wod20_advantages.each { |s| s.delete }

      WOD20Skills.attr_names.each do |a|
        WOD20Skills.set_ability(char, a, 2)
      end

      WOD20Skills.action_skill_names.each do |a|
        WOD20Skills.set_ability(char, a, 1)
      end

      starting_skills = StartingSkills.get_groups_for_char(char)

      starting_skills.each do |k, v|
        set_starting_skills(char, k, v)
      end
    end

    def self.set_starting_skills(char, group, skill_config)
      return if !skill_config

      skills = skill_config["skills"]
      return if !skills

      skills.each do |k, v|
        WOD20Skills.set_ability(char, k, v)
      end
    end
  end
end
