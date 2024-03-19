module AresMUSH
  module WOD20Skills
    class WebCharDataBuilder
      def build(char, viewer)
        is_owner = (viewer && viewer.id == char.id)

        show_sheet = WOD20Skills.can_view_sheets?(viewer) || is_owner

        if (WOD20Skills.can_view_xp?(viewer, char))
          xp = {
            attributes: get_xp_list(char, char.wod20_attributes),
            action_skills: get_xp_list(char, char.wod20_action_skills),
            backgrounds: get_xp_list(char, char.wod20_background_skills),
            languages: get_xp_list(char, char.wod20_languages),
            advantages: get_xp_list(char, char.wod20_advantages),
            xp_points: char.wod20_xp,
            can_learn: AresCentral.is_alt?(char, viewer),
            allow_advantages_xp: Global.read_config("w20skills", "allow_advantages_xp")
          }
        else
          xp = nil
        end

        if (show_sheet)
          {
            attributes: get_ability_list(char.wod20_attributes),
            action_skills: get_ability_list(char.wod20_action_skills, true),
            backgrounds: get_ability_list(char.wod20_background_skills),
            languages: get_ability_list(char.wod20_languages),
            advantages: get_ability_list(char.wod20_advantages),
            use_advantages: WOD20Skills.use_advantages?,
            damage: damage,
            damage_mod: damage_mod,
            show_sheet: show_sheet,
            luck_points: char.luck.floor,
            xp: xp
          }
        else
          {
            damage: damage,
            damage_mod: damage_mod,
            show_sheet: show_sheet,
            xp: xp
          }
        end
      end

      def get_ability_list(list, include_specs = false)
        list.to_a.sort_by { |a| a.name }.map { |a|
          {
            name: a.name,
            rating: a.rating,
            rating_name: a.rating_name,
            specialties: include_specs ? a.specialties.join(", ") : nil,
            linked_attr: include_specs ? WOD20Skills.get_linked_attr(a.name)[0..2].upcase : nil
          }}
      end

      def get_xp_list(char, list)
        list.to_a.sort_by { |a| a.name }.map { |a| {
          name: a.name,
          rating: a.rating,
          can_raise: !WOD20Skills.check_can_learn(char, a.name, a.rating),
          progress: a.xp_needed ? a.xp * 100.0 / a.xp_needed : 0,
          xp: a.xp,
          xp_needed: a.xp_needed,
          days_to_learn: WOD20Skills.days_to_next_learn(a)
        }}
      end
    end
  end
end
