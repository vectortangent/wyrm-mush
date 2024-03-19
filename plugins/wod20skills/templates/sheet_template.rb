module AresMUSH
  module WOD20Skills
    class SheetTemplate < ErbTemplateRenderer

      attr_accessor :char, :client, :section

      def initialize(char, client, section = nul)
        @char = char
        @client = client
        @section = section
        super File.dirname(__FILE__) + "/sheet.erb"
      end

      def approval_status
        Chargen.approval_status(@char)
      end

      def luck
        @char.luck.floor
      end

      def show_section(section)
        sections = ['attributes', 'action', 'background', 'languages', 'advantages']
        return true if self.section.blank?
        return true if !sections.include?(section)
        return true if !sections.include?(self.section)
        return section == self.section
      end

      def attrs
       list = []
        @char.wod20_attributes.sort_by(:name, :order => "ALPHA").each_with_index do |a, i|
          list << format_attr(a, i)
        end
        list
      end

      def action_skills
        list = []
        @char.wod20_action_skills.sort_by(:name, :order => "ALPHA").each_with_index do |s, i|
           list << format_skill(s, i, true)
        end
        list
      end

      def background_skills
        list = []
        @char.wod20_background_skills.sort_by(:name, :order => "ALPHA").each_with_index do |s, i|
           list << format_skill(s, i)
        end
        list
      end

      def languages
        list = []
        @char.wod20_languages.sort_by(:name, :order => "ALPHA").each_with_index do |l, i|
          list << format_skill(l, i)
        end
        list
      end

      def advantages
        list = []
        @char.wod20_advantages.sort_by(:name, :order => "ALPHA").each_with_index do |l, i|
          list << format_skill(l, i)
        end
        list
      end

      def use_advantages
        WOD20Skills.use_advantages?
      end

      def specialties
        spec = {}
        @char.wod20_action_skills.each do |a|
          if (a.specialties)
            a.specialties.each do |s|
              spec[s] = a.name
            end
          end
        end
        return nil if (spec.keys.count == 0)
        spec.map { |spec, ability| "#{spec} (#{ability})"}.join(", ")
      end

      def format_attr(a, i)
        name = "%xh#{a.name}:%xn"
        linebreak = i % 2 == 1 ? "" : "%r"
        rating_text = "#{a.rating_name}"
        rating_dots = @client.screen_reader ? a.rating : a.print_rating
        "#{linebreak}#{left(name, 14)} #{left(rating_dots, 8)} #{left(rating_text,16)}"
      end

      def format_skill(s, i, show_linked_attr = false)
        name = "%xh#{s.name}:%xn"
        linked_attr = show_linked_attr ? print_linked_attr(s) : ""
        linebreak = i % 2 == 1 ? "" : "%r"
        rating_text = "#{s.rating_name}#{linked_attr}"
        rating_dots = @client.screen_reader ? s.rating : s.print_rating
        "#{linebreak}#{left(name, 14)} #{left(rating_dots, 8)} #{left(rating_text, 16)}"
      end

      def print_linked_attr(skill)
        apt = WOD20Skills.get_linked_attr(skill.name)
        !apt ? "" : " %xh%xx(#{apt[0..2].upcase})%xn"
      end

      def section_line(title)
        @client.screen_reader ? title : line_with_text(title)
      end
    end
  end
end
