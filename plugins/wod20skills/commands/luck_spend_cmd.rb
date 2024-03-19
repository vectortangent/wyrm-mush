module AresMUSH
  module WOD20Skills
    class LuckSpendCmd
      include CommandHandler

      attr_accessor :reason

      def parse_args
        self.reason = trim_arg(cmd.args)
      end

      def required_args
        [ self.reason ]
      end

      def check_luck
        return t('wod20skills.not_enough_points') if enactor.luck < 1
        return nil
      end

      def handle
        WOD20Skills.spend_luck(enactor, self.reason, enactor_room.scene)
      end
    end
  end
end
