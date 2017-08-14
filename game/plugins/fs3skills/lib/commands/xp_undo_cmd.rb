module AresMUSH

  module FS3Skills
    class XpUndoCmd
      include CommandHandler
      
      attr_accessor :name, :skill

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.name = titlecase_arg(args.arg1)
        self.skill = titlecase_arg(args.arg2)
      end

      def required_args
        [ self.name, self.skill ]
      end
      
      def check_can_award
        return nil if FS3Skills.can_manage_xp?(enactor)
        return t('dispatcher.not_allowed')
      end
      
      def handle
        ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
          ability = FS3Skills.find_ability(model, self.skill)
          if (!ability)
            client.emit_failure t('fs3skills.ability_not_found')
            return
          end
          ability.update(xp: ability.xp - 1)
          ability.update(last_learned: nil)
          model.award_xp 1
          client.emit_success t('fs3skills.xp_undone', :name => model.name, :skill => self.skill)
        end
      end
    end
  end
end
