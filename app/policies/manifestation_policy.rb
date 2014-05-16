class ManifestationPolicy < AdminPolicy
  def index?
    true
  end

  def show?
    if user
      user.role.id >= record.required_role.id
    else
      true if record.required_role.name == 'Guest'
    end
  end

  def create?
    user.try(:has_role?, 'Librarian')
  end

  def update?
    user.try(:has_role?, 'Librarian')
  end

  def destroy?
    user.try(:has_role?, 'Librarian')
  end
end
