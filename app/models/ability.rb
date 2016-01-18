class Ability
  include CanCan::Ability

  def initialize(member)
    if member
      if member.role.admin?
        can :manage, :all
      else
        can :manage, :all
      end
    end
  end
end
