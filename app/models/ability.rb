class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can :manage, User, id: user.id
      can :manage, GroupedIssue
      can :manage, Issue
      can :manage, Message
      can :manage, Subscriber do |subscriber|
        user.is_owner_of?(subscriber.website)
      end
      can :manage, Website do |website|
        user.is_owner_of?(website)
      end
      can :read, Website do |website|
        user.is_user_of?(website)
      end
      can :create, Website
      can :manage, WebsiteMember do |website_member|
        user.is_owner_of?(website_member.website)
      end
      can :read, WebsiteMember do |website_member|
        website_member.website.is_user_of?(user)
      end
    end
  end
end
