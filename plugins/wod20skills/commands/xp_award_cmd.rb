module AresMUSH

  module WOD20Skills
    class XpAwardCmd
      include CommandHandler

      attr_accessor :name, :xp

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.name = trim_arg(args.arg1)
        self.xp = integer_arg(args.arg2)
        if (cmd.switch_is?("remove") && self.xp)
          self.xp = 0 - self.xp
        end
      end

      def required_args
        [ self.name, self.xp ]
      end

      def check_xp
        return nil if !self.xp
        return t('wod20skills.invalid_xp_award') if self.xp == 0
        return nil
      end

      def check_can_award
        return nil if WOD20Skills.can_manage_xp?(enactor)
        return t('dispatcher.not_allowed')
      end

      def handle
        ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
          if (model.wod20_xp + self.xp < 0)
            client.emit_failure  t('wod20skills.invalid_xp_award')
            return
          end

          model.award_xp self.xp
          Global.logger.info "#{self.xp} XP Awarded by #{enactor_name} to #{model.name}"
          if (self.xp < 0)
            client.emit_success t('wod20skills.xp_removed', :name => model.name, :xp => -self.xp)
          else
            client.emit_success t('wod20skills.xp_awarded', :name => model.name, :xp => self.xp)
          end
        end
      end
    end
  end
end
