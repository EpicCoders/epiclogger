class ApiAbility
  include CanCan::Ability

  def initialize(user)
    if user
      can :manage, User, id: user.id
      can :manage, GroupedIssue do |group|
        user.is_owner_of?(group.website)
      end
      can :manage, Issue do |issue|
        user.is_owner_of?(issue.group.website)
      end
      can :manage, Message do |message|
        user.is_owner_of?(message.issue.group.website)
      end
      can :manage, Subscriber do |subscriber|
        user.is_owner_of?(subscriber.website)
      end
      can :manage, Website do |website|
        user.is_owner_of?(website)
      end
      can :create, Website
      can :manage, WebsiteMember do |website_member|
        user.is_owner_of?(website_member.website)
      end
      can :read, WebsiteMember do |website_member|
        website_member.website.members.include?(user)
      end
    end
  end
end
