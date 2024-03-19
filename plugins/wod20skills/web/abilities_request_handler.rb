module AresMUSH
  module WOD20Skills
    class AbilitiesRequestHandler
      def handle(request)
        attrs = WOD20Skills.attrs.map { |a| { name: a['name'].titleize, description: a['desc'] } }
        backgrounds = WOD20Skills.background_skills.map { |name, desc| { name: name, description: desc } }
        action_skills = WOD20Skills.action_skills.sort_by { |a| a['name'] }.map { |a| {
          name: a['name'].titleize,
          linked_attr: a['linked_attr'],
          description: a['desc'],
          specialties: a['specialties'] ? a['specialties'].join(', ') : nil,
        }}
        languages = WOD20Skills.languages.sort_by { |a| a['name'] }.map { |a| { name: a['name'], description: a['desc'] } }
        advantages = WOD20Skills.advantages.sort_by { |a| a['name'] }.map { |a| { name: a['name'], description: a['desc'] } }

        {
          attrs_blurb: Website.format_markdown_for_html(WOD20Skills.attr_blurb),
          action_blurb: Website.format_markdown_for_html(WOD20Skills.action_blurb),
          background_blurb: Website.format_markdown_for_html(WOD20Skills.bg_blurb),
          language_blurb: Website.format_markdown_for_html(WOD20Skills.language_blurb),
          advantages_blurb:  Website.format_markdown_for_html(WOD20Skills.advantages_blurb),

          attrs: attrs,
          action_skills: action_skills,
          backgrounds: backgrounds,
          languages: languages,
          advantages: advantages,
          use_advantages: WOD20Skills.use_advantages?
        }
      end
    end
  end
end
