# Patches Redmine's Issues dynamically.  Adds a default assignee per
# project.
module DefaultAssignIssuePatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable

      before_create :assign_default_assignee
    end
  end

  module InstanceMethods
    # If the issue isn't assigned to someone and a default assignee
    # is set, set it.
    def assign_default_assignee
      return  if not self.assigned_to.nil?
      default_assignee = self.project.default_assignee
      if default_assignee.blank?
        self_assignment =
          Setting.plugin_redmine_default_assign['self_assignment'] || 'false'
        self_assignment = (self_assignment == 'true')
        if self_assignment
          default_assignee = User.current
        else
          return
        end
      end
      if self.project.assignable_users.include?(default_assignee)
        self.assigned_to = default_assignee
      end
    end
  end
end
