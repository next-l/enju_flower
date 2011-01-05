class Ability
  include CanCan::Ability

  def initialize(user, ip_address)
    case user.try(:role).try(:name)
    when 'Administrator'
      can :manage, [PurchaseRequest, Reserve]
      can :read, :all
    else
      can :read, :all
    end
  end
end
