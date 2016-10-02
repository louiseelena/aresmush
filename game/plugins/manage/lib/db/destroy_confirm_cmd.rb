module AresMUSH
  module Manage
    class DestroyConfirmCmd
      include CommandHandler
      include CommandWithoutArgs
      include CommandRequiresLogin
      
      def handle
        target_id = client.program[:destroy_target]
        target_class = client.program[:destroy_class]
        
        if (!target_id)
          client.emit_failure t('manage.no_destroy_in_progress')
          return
        end
        
        results = ClassTargetFinder.find("#{target_id}", target_class, enactor)
        if (!results.found?)
          client.emit_failure results.error
          return
        end
       
        target = results.target
       
        if (!Manage.can_manage_object?(enactor, target))
          client.emit_failure t('dispatcher.not_allowed')
          return
        end
        
        if (target.class == Character)
          if (target.is_online?)
            client.emit_failure t('manage.cannot_destroy_online')
            return
          end
        end
        
        if (target.class == Room)
          target.characters.each do |c|
            connected_client = c.client
            if (connected_client)
              connected_client.emit_ooc t('manage.room_being_destroyed')
            end
            Rooms::Api.send_to_welcome_room(connected_client, c)
          end
        end
        target.delete
        client.emit_success t('manage.object_destroyed', :name => target.name)
        client.program.delete(:destroy_target)
      end
    end
  end
end
