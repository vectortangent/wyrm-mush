module AresMUSH
  module WOD20Skills
    class AbilityPageTemplate < ErbTemplateRenderer


      attr_accessor :data

      def initialize(file, data)
        @data = data
        super File.dirname(__FILE__) + file
      end

      def page_footer
        footer = t('pages.page_x_of_y', :x => @data[:page], :y => @data[:num_pages])
        template = PageFooterTemplate.new(footer)
        template.render
      end

      def attr_blurb
        WOD20Skills.attr_blurb
      end

      def advantages_blurb
        WOD20Skills.advantages_blurb
      end

      def action_blurb
        WOD20Skills.action_blurb
      end

      def bg_blurb
        WOD20Skills.bg_blurb
      end

      def lang_blurb
        WOD20Skills.language_blurb
      end

    end
  end
end
