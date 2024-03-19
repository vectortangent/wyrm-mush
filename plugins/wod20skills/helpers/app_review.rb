module AresMUSH
  module WOD20Skills

    def self.backgrounds_review(char)
      WOD20Skills.min_item_review(char.wod20_background_skills.count, "min_backgrounds", "wod20skills.backgrounds_added")
    end

    def self.ability_rating_review(char)
      too_high = []
      message = t('wod20skills.ability_ratings_check')

      max_skills = Global.read_config('wod20skills', 'max_skills_at_or_above')
      max_skills.each do |rating, limit|
        error = WOD20Skills.check_high_abilities(char.wod20_action_skills, rating, limit, 'wod20skills.action_skills_above')
        too_high << error if error
      end

      max_attrs = Global.read_config('wod20skills', 'max_attrs_at_or_above')
      max_attrs.each do |rating, limit|
        error = WOD20Skills.check_high_abilities(char.wod20_attributes, rating, limit, 'wod20skills.attributes_above')
        too_high << error if error
      end

      error = WOD20Skills.check_attr_points(char)
      too_high << error if error

      error = WOD20Skills.check_action_points(char)
      too_high << error if error

      error = WOD20Skills.check_advantage_points(char)
      too_high << error if error


      if (too_high.count == 0)
        Chargen.format_review_status(message, t('chargen.ok'))
      else
        error = too_high.collect { |m| "%T#{m}" }.join("%R")
        "#{message}%r#{error}"
      end
    end

    def self.unusual_skills_check(char)
      too_high = []
      message = t('wod20skills.unusual_abilities_check')

      all_skills = char.wod20_background_skills.map { |s| s.name }
      all_skills.concat char.wod20_action_skills.select { |s| s.rating > 1 }.map { |s| s.name }
      all_skills.concat char.wod20_languages.map { |s| s.name }

      uncommon_skills = Global.read_config("wod20skills", "unusual_skills") || []
      uncommon_skills.each do |s|
        if (all_skills.include?(s))
          too_high << t('wod20skills.unusual_skill', :skill => s)
        end
      end

      char.wod20_background_skills.each do |b|
        if (b.rating > 1)
          too_high << t('wod20skills.high_bg', :skill => b.name)
        end
      end

      if (too_high.count == 0)
        Chargen.format_review_status(message, t('chargen.ok'))
      else
        error = too_high.collect { |m| "%T#{m}" }.join("%R")
        "#{message}%r#{error}"
      end
    end

    def self.check_attr_points(char)
      points = AbilityPointCounter.points_on_attrs(char)
      max = Global.read_config("wod20skills", "max_points_on_attrs")
      points > max ? t('wod20skills.too_many_attributes', :max => max) : nil
    end

    def self.check_action_points(char)
      points = AbilityPointCounter.points_on_action(char)
      max = Global.read_config("wod20skills", "max_points_on_action")
      points > max ? t('wod20skills.too_many_action_skills', :max => max) : nil
    end

    def self.check_advantage_points(char)
      points = AbilityPointCounter.points_on_advantages(char)
      max = Global.read_config("wod20skills", "max_points_on_advantages") || 99
      points > max ? t('wod20skills.too_many_advantages', :max => max) : nil
    end

    def self.total_point_review(char)
      points =  AbilityPointCounter.total_points(char)
      max = Global.read_config("wod20skills", "max_ap")
      error = points > max ? t('chargen.too_many') : t('chargen.ok')
      Chargen.format_review_status(t('wod20skills.total_points_spent', :total => points, :max => max), error)
    end

    def self.starting_skills_check(char)
      message = t('wod20skills.starting_skills_check')
      missing = []
      starting_skills = StartingSkills.get_skills_for_char(char)
      starting_skills.each do |skill, rating|
        if (WOD20Skills.ability_rating(char, skill)) < rating
          missing << t('wod20skills.missing_starting_skill', :skill => skill, :rating => rating)
        end
      end

      starting_specs = StartingSkills.get_specialties_for_char(char)
      char.wod20_action_skills.each do |a|
        specs_for_skill = starting_specs[a.name]
        if (specs_for_skill)
          specs_for_skill.each do |s|
            if (!a.specialties.include?(s))
              missing << t('wod20skills.missing_group_specialty', :spec => s, :skill => a.name)
            end
          end
        end
      end

      char.wod20_action_skills.each do |a|
        config = WOD20Skills.action_skill_config(a.name)
        if (config['specialties'] && a.specialties.empty? && a.rating > 2)
          missing << t('wod20skills.missing_specialty', :skill => a.name)
        end
      end


      if (missing.count == 0)
        Chargen.format_review_status(message, t('chargen.ok'))
      else
        error = missing.collect { |m| "%T#{m}" }.join("%R")
        "#{message}%r#{error}"
      end
    end

    def self.check_high_abilities(abilities, top_rating, num_abilities_max, prompt)
      ratings = abilities.map { |a| a.rating }
      # Goofiness needed because the config keys could be strings or ints.
      top_rating = top_rating.to_i
      count = ratings.inject(0) { |count, a| count + (a >= top_rating ? 1 : 0) }
      if (count > num_abilities_max)
        prompt = t(prompt, :num => count, :max => num_abilities_max, :high_rating => top_rating)
        return prompt
      else
        return nil
      end
    end

    def self.min_item_review(count, min_config_option_name, prompt)
      min = Global.read_config("wod20skills", min_config_option_name)
      error = count < min ? t('chargen.not_enough') : t('chargen.ok')
      Chargen.format_review_status(t(prompt, :num => count, :min => min), error)
    end

  end
end
