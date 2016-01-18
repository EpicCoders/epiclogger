class Ability
  include CanCan::Ability

  def initialize(member)
    member ||= Member.new
    if member
      can :manage, GroupedIssue
      can :manage, Issue
      can :manage, Message
      can :manage, Notification
      can :manage, Subscriber
      can :manage, Website
      can :manage, WebsiteMember
    end
  end
end
