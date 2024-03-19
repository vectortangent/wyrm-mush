module AresMUSH

  module WOD20Skills
    class LearnAbilityCmd
      include CommandHandler

      attr_accessor :name

      def parse_args
        self.name = titlecase_arg(cmd.args)
      end

      def required_args
        [ self.name ]
      end

      def check_chargen_locked
        return t('wod20skills.must_be_approved') if !enactor.is_approved?
        return nil
      end

      def check_xp
        return t('wod20skills.not_enough_xp') if enactor.xp <= 0
      end

      def handle
        error = WOD20Skills.learn_ability(enactor, self.name)
        if (error)
          client.emit_failure error
        else
          client.emit_success t('wod20skills.xp_spent', :name => self.name)
        end
      end
    end
  end
end
