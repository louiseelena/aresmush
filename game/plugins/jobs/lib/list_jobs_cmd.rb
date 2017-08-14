module AresMUSH
  module Jobs
    class ListJobsCmd
      include CommandHandler
      
      def help
        "`jobs` - Lists jobs\n" +
        "`job <#>` - Views a job.\n" + 
        "`jobs/all` - Lists all jobs, even closed ones."
      end
      
      def check_can_access
        return t('dispatcher.not_allowed') if !Jobs.can_access_jobs?(enactor)
        return nil
      end
      
      def handle
        jobs = Jobs.filtered_jobs(enactor)
        paginator = Paginator.paginate(jobs, cmd.page, 20)
        template = JobsListTemplate.new(enactor, paginator)
        client.emit template.render
      end
    end
  end
end
