module AresMUSH

  module WOD20Skills
    class AbilitiesCmd
      include CommandHandler

      def handle

        num_pages = WOD20Skills.use_advantages? ? 5 : 4

        case cmd.page
        when 1
          template = AbilityPageTemplate.new("/attributes.erb",
              { attrs: WOD20Skills.attrs, num_pages: num_pages, page: cmd.page })
        when 2
          template = AbilityPageTemplate.new("/action_skills.erb",
              { skills: WOD20Skills.action_skills.sort_by { |a| a['name'] }, num_pages: num_pages, page: cmd.page })
        when 3
          template = AbilityPageTemplate.new("/background_skills.erb",
              { skills: WOD20Skills.background_skills, num_pages: num_pages, page: cmd.page } )
        when 4
          template = AbilityPageTemplate.new("/languages.erb",
              { skills: WOD20Skills.languages.sort_by { |a| a['name'] }, num_pages: num_pages, page: cmd.page })
        when 5
          if (WOD20Skills.use_advantages?)
            template = AbilityPageTemplate.new("/advantages.erb",
               { advantages: WOD20Skills.advantages.sort_by { |a| a['name'] }, num_pages: num_pages, page: cmd.page })
           else
             client.emit_failure t('pages.not_that_many_pages')
             return
           end
        else
          client.emit_failure t('pages.not_that_many_pages')
          return
        end

        client.emit template.render
      end
    end
  end
end
