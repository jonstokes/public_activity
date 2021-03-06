module PublicActivity
  module ORM
    module ActiveRecord
      # The ActiveRecord model containing
      # details about recorded activity.
      class Activity < ::ActiveRecord::Base
        include Renderable
        self.table_name = PublicActivity.config.table_name

        # Define polymorphic association to the parent
        belongs_to :trackable, :polymorphic => true
        # Define ownership to a resource responsible for this activity
        belongs_to :owner, :polymorphic => true
        # Define ownership to a resource targeted by this activity
        belongs_to :recipient, :polymorphic => true

        enum visibility: [:everyone, :followers, :with_link, :me]
        enum action: [:action_create, :action_update, :action_delete]
        before_save :set_visibility, :set_action

        if ::ActiveRecord::VERSION::MAJOR < 4 || defined?(ProtectedAttributes)
          attr_accessible :key, :owner, :parameters, :recipient, :trackable
        end

        private

        def set_action
          self.action = "action_#{key.split(".").last}"
        end

        def set_visibility
          if recipient && recipient.respond_to?(:visibility)
            self.visibility = recipient.visibility
          elsif trackable.respond_to?(:visibility)
            self.visibility = trackable.visibility
          end
          true
        end
      end
    end
  end
end
