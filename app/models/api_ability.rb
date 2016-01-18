class ApiAbility
  include CanCan::Ability

  def initialize(member)
    member ||= Member.new
    if member
      #
    else
      #
    end
    can :manage, :all
  end
end