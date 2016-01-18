class ApiAbility
  include CanCan::Ability

  def initialize(member)
    if member
      #
    else
      #
    end
    can :manage, :all
  end
end