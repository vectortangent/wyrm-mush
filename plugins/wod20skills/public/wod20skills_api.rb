module AresMUSH

  module WOD20Skills
    class RollParams

      attr_accessor :ability, :modifier, :linked_attr

      def initialize(ability, modifier = 0, linked_attr = nil)
        self.ability = ability
        self.modifier = modifier
        self.linked_attr = linked_attr
      end

      def to_s
        "#{self.ability} mod=#{self.modifier} linked_attr=#{self.linked_attr}"
      end
    end

    def self.is_enabled?
      !Global.plugin_manager.is_disabled?("wod20skills")
    end


    # Makes an ability roll and returns a hash with the successes and success title.
    # Good for automated systems where you only care about the final result and don't need
    # to know the raw die roll.
    def self.one_shot_roll(char, roll_params)
      roll = WOD20Skills.roll_ability(char, roll_params)
      roll_result = WOD20Skills.get_success_level(roll)
      success_title = WOD20Skills.get_success_title(roll_result)

      {
        :successes => roll_result,
        :success_title => success_title
      }
    end

    # Rolls a raw number of dice.
    def self.one_shot_die_roll(dice)
      roll = WOD20Skills.roll_dice(dice)
      roll_result = WOD20Skills.get_success_level(roll)
      success_title = WOD20Skills.get_success_title(roll_result)

      Global.logger.info "Rolling raw dice=#{dice} result=#{roll}"

      {
        :successes => roll_result,
        :success_title => success_title
      }
    end


    def self.app_review(char)
      text = WOD20Skills.total_point_review(char)
      text << "%r"
      text << WOD20Skills.ability_rating_review(char)
      text << "%r"
      text << WOD20Skills.backgrounds_review(char)
      text << "%r%r"
      text << WOD20Skills.starting_skills_check(char)
      text << "%r"
      text << WOD20Skills.unusual_skills_check(char)
      text
    end

    def self.ability_rating(char, ability_name)
      ability = WOD20Skills.find_ability(char, ability_name)
      ability ? ability.rating : 0
    end

    # Dice they roll, including related attribute
    def self.dice_rolled(char, ability)
      WOD20Skills.dice_to_roll_for_ability(char, RollParams.new(ability))
    end

    def self.save_char(char, chargen_data)
      alerts = []
      (chargen_data[:wod20][:wod20_attributes] || {}).each do |k, v|
        error = WOD20Skills.set_ability(char, k, v.to_i)
        if (error)
          alerts << t('wod20skills.error_saving_ability', :name => k, :error => error)
        end
      end

      (chargen_data[:wod20][:wod20_action_skills] || {}).each do |k, v|
        error = WOD20Skills.set_ability(char, k, v.to_i)
        if (error)
          alerts << t('wod20skills.error_saving_ability', :name => k, :error => error)
        end

        ability = WOD20Skills.find_ability(char, k)
        if (ability)
          specs = (chargen_data[:wod20][:wod20_specialties] || {})[k] || []
          ability.update(specialties: specs)
        end
      end

      new_bg_skills = []
      (chargen_data[:wod20][:wod20_backgrounds] || {}).each do |k, v|
        skill_name = k.titleize
        error = WOD20Skills.set_ability(char, skill_name, v.to_i)
        if (error)
          alerts << t('wod20skills.error_saving_ability', :name => k, :error => error)
        end
        new_bg_skills << skill_name
      end

      # Remove any BG skills that they no longer have
      char.wod20_background_skills.each do |bg|
        if (!new_bg_skills.include?(bg.name))
          WOD20Skills.set_ability(char, bg.name, 0)
        end
      end

      (chargen_data[:wod20][:wod20_languages] || {}).each do |k, v|
        error = WOD20Skills.set_ability(char, k, v.to_i)
        if (error)
          alerts << t('wod20skills.error_saving_ability', :name => k, :error => error)
        end
      end

      (chargen_data[:wod20][:wod20_advantages] || {}).each do |k, v|
        error = WOD20Skills.set_ability(char, k, v.to_i)
        if (error)
          alerts << t('wod20skills.error_saving_ability', :name => k, :error => error)
        end
      end
      return alerts
    end

    def self.luck_for_scene(char, scene)
      luck_for_scene = 0
      luck_tracker = char.wod20_scene_luck
      luck_config = Global.read_config('wod20skills', 'luck_for_scene') || {}
      regular_luck = luck_config[0] || 0.1

      scene.participants.each do |p|
        next if p == char

        days_old = (Time.now - p.created_at) / 86400
        # First-Time RP Bonus
         if (!luck_tracker.has_key?(p.id))
          luck_tracker[p.id] = 1
          # Newbie Bonus
          if (days_old < 30)
            luck_for_scene += regular_luck * 3
          else
            luck_for_scene += regular_luck * 2
          end
        # Diminising returns for the same person
        else
          num_scenes = luck_tracker[p.id]
          luck_for_participant = regular_luck
          luck_config.each do |scene_threshold, luck|
            if (num_scenes > scene_threshold.to_i)
              luck_for_participant = luck
            end
          end
          luck_for_scene += luck_for_participant
          luck_tracker[p.id] = luck_tracker[p.id] + 1
        end
      end

      if (luck_for_scene > 0)
        char.award_luck(luck_for_scene)
        char.update(wod20_scene_luck: luck_tracker)
      end
    end

    def self.build_web_char_data(char, viewer)
      builder = WebCharDataBuilder.new
      builder.build(char, viewer)
    end
  end
end
