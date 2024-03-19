module AresMUSH
  module WOD20Skills
    class XpCronHandler
      def on_event(event)
        config = Global.read_config("wod20skills", "xp_cron")
        return if !Cron.is_cron_match?(config, event.time)

        Global.logger.debug "XP awards."

        periodic_xp = Global.read_config("wod20skills", "periodic_xp")
        max_xp = Global.read_config("wod20skills", "max_xp_hoard")

        approved = Chargen.approved_chars
        approved.each do |a|
          WOD20Skills.modify_xp(a, periodic_xp)
        end
      end
    end
  end
end
