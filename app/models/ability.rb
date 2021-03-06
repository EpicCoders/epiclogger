class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can :manage, User, id: user.id
      can :manage, GroupedIssue do |group|
        user.is_member_of?(group.website)
      end
      can :manage, Issue do |issue|
        user.is_member_of?(issue.website)
      end
      can :manage, Message do |message|
        user.is_member_of?(message.subscriber.website)
      end
      can :manage, Subscriber do |subscriber|
        user.is_owner_of?(subscriber.website)
      end
      can :manage, Website do |website|
        user.is_owner_of?(website)
      end
      can [:change_current, :read], Website do |website|
        user.is_member_of?(website)
      end
      can :manage, Integration do |integration|
        user.is_owner_of?(integration.website)
      end
      can :create, Website
      can :manage, WebsiteMember do |website_member|
        user.is_owner_of?(website_member.website)
      end
      can [:read, :update], WebsiteMember, user_id: user.id
      cannot :change_role, WebsiteMember do |website_member|
        user.is_member_of?(website_member.website)
      end
      can :change_role, WebsiteMember do |website_member|
        user.is_owner_of?(website_member.website)
      end
    end
  end
end
