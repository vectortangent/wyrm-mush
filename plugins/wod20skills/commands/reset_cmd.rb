module AresMUSH

  module WOD20Skills
    class ResetCmd
      include CommandHandler

      def check_chargen_locked
        Chargen.check_chargen_locked(enactor)
      end

      def handle
        WOD20Skills.reset_char(enactor)
        client.emit_success t('wod20skills.reset_complete')
      end
    end
  end
end
