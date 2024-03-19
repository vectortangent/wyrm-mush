module AresMUSH

  module WOD20Skills
    class WipeAbilityCmd
      include CommandHandler

      attr_accessor :name

      def parse_args
        self.name = titlecase_arg(cmd.args)
      end

      def check_can_set
        return nil if WOD20Skills.can_manage_abilities?(enactor)
        return t('dispatcher.not_allowed')
      end

      def handle
        WOD20ActionSkill.all.each do |a|
          delete_ability(a)
        end
        WOD20Language.all.each do |a|
          delete_ability(a)
        end
        WOD20BackgroundSkill.all.each do |a|
          delete_ability(a)
        end
        WOD20Advantage.all.each do |a|
          delete_ability(a)
        end
        WOD20Attribute.all.each do |a|
          delete_ability(a)
        end

      end

      def delete_ability(ability)
        if (ability.name == self.name)
          client.emit "Deleting #{ability.character.name}'s #{ability.class} #{ability.name} -- was at rating #{ability.rating}."
          ability.delete
        end
      end

    end
  end
end
