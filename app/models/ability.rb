class Ability
  include CanCan::Ability

  def initialize(user)
    case user.try(:role).try(:name)
    when 'Administrator'
      can :read, :all
    else
      can :read, :all
    end
  end
end
