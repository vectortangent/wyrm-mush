module AresMUSH
  module WOD20Skills
    class CharIdledOutEventHandler
      def on_event(event)
        # No need to reset if they're getting destroyed.
        return if event.is_destroyed?

        Global.logger.debug "Clearing XP for #{event.char_id}"
        char = Character[event.char_id]
        if (char.wod20_xp > 0)
          char.reset_xp
        end
      end
    end
  end
end
