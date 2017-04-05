module AresMUSH
  module Jobs
    class JobMailCmd
      include SingleJobCmd

      attr_accessor :names, :message
      
      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2_slash_arg3)
        self.number = trim_arg(args.arg1)
        self.names = split_and_titlecase_arg(args.arg2)
        self.message = args.arg3
      end
      
      def required_args
        {
          args: [ self.number, self.names, self.message ],
          help: 'jobs'
        }
      end
      
      def handle
        Jobs.with_a_job(client, self.number) do |job|  
          Mail::Api.send_mail(self.names, "Job Notice - #{job.title}", self.message, client, enactor)
          display_names = self.names.join(" ")
          
          # Create an admin-only comment for the mail   
          Jobs.comment(job, enactor, t('jobs.mail_comment', :names => display_names, :message => self.message), true)
          
          client.emit_success t('jobs.mail_sent', :names => display_names)
        end
      end
    end
  end
end