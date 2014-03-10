class ManifestationPolicy < AdminPolicy
  def show?
    if user
      user.role.id >= record.required_role.id
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
