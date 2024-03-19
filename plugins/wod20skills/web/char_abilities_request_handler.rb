module AresMUSH
  module WOD20Skills
    class CharAbilitiesRequestHandler
      def handle(request)
        char = Character.find_one_by_name request.args[:id]
        enactor = request.enactor

        if (!char)
          return []
        end

        error = Website.check_login(request, true)
        return error if error


        can_view = WOD20Skills.can_view_sheets?(enactor) || (enactor && enactor.id == char.id)
        if (!can_view)
          return { error: t('dispatcher.not_alllowed') }
        end

        abilities = []

        [ char.wod20_attributes, char.wod20_action_skills, char.wod20_background_skills, char.wod20_languages, char.wod20_advantages ].each do |list|
          list.each do |a|
            abilities << a.name
          end
        end

        return abilities
      end
    end
  end
end
