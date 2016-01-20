class ApiAbility
  include CanCan::Ability

  def initialize(member)
    if member
      can :manage, Member, id: member.id
      can :manage, GroupedIssue do |group|
        member.is_owner_of?(group.website)
      end
      can :manage, Issue do |issue|
        member.is_owner_of?(issue.group.website)
      end
      can :manage, Message do |message|
        member.is_owner_of?(message.issue.group.website)
      end
      can :manage, Notification do |notification|
        member.is_owner_of?(notification.website)
      end
      can :manage, Subscriber do |subscriber|
        member.is_owner_of?(subscriber.website)
      end
      can :manage, Website do |website|
        member.is_owner_of?(website)
      end
      can :create, Website
      can :manage, WebsiteMember do |website_member|
        member.is_owner_of?(website_member.website)
      end
      can :read, WebsiteMember do |website_member|
        website_member.website.members.include?(member)
      end
    end
  end
end
