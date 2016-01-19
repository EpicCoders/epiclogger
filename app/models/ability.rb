class Ability
  include CanCan::Ability

  def initialize(member)
    if member
      can :manage, :all
    end
  end
end
