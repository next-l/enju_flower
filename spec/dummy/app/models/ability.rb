class Ability
  include CanCan::Ability

  def initialize(user, ip_addess = nil)
    case user.try(:role).try(:name)
    when 'Administrator'
      can [:read, :update], ContentType
      can [:read, :update], Country
      can :manage, Create
      can :manage, CreateType
      can :manage, Donate
      can :manage, Exemplify
      can [:read, :update], Extent
      can [:read, :update], Frequency
      can [:read, :update], FormOfWork
      can [:read, :create, :update], Item
      can :destroy, Item do |item|
        item.deletable?
      end
      can :manage, ImportRequest
      can [:read, :update], Language
      can [:read, :update], License
      can [:read, :create, :update], Manifestation
      can :destroy, Manifestation do |manifestation|
        if defined?(EnjuCirculation)
          manifestation.items.empty? and !manifestation.periodical_master? and !manifestation.is_reserved?
        else
          manifestation.items.empty? and !manifestation.periodical_master?
        end
      end
      can [:read, :update], MediumOfPerformance
      can :manage, Own
      can [:read, :create, :update], Patron
      can :destroy, Patron do |patron|
        true
      end
      can :manage, CarrierType
      can :manage, PatronImportFile
      can :read, PatronImportResult
      can :manage, PatronRelationship
      can :manage, PatronRelationshipType
      can [:read, :update], PatronType
      can :manage, PictureFile
      can :manage, Produce
      can :manage, ProduceType
      can :manage, ManifestationRelationship
      can :manage, ManifestationRelationshipType
      can :manage, Realize
      can :manage, RealizeType
      can :manage, ResourceImportFile
      can :read, ResourceImportResult
      can :manage, SeriesHasManifestation
      can :manage, SeriesStatement
      can :manage, SeriesStatementRelationship
    when 'Librarian'
      can [:read, :update], CarrierType
      can :read, ContentType
      can :read, Country
      can :manage, Create
      can :manage, Donate
      can :manage, Exemplify
      can :read, Extent
      can :read, Frequency
      can :read, FormOfWork
      can :manage, ImportRequest
      can [:read, :create, :update], Item
      can :destroy, Item do |item|
        if defined?(EnjuCirculation)
          item.checkouts.not_returned.empty?
        else
          true
        end
      end
      can :read, Language
      can :read, License
      can [:read, :create, :update], Manifestation
      can :destroy, Manifestation do |manifestation|
        if defined?(EnjuCirculation)
          manifestation.items.empty? and !manifestation.periodical_master? and !manifestation.is_reserved?
        else
          manifestation.items.empty? and !manifestation.periodical_master?
        end
      end
      can :read, MediumOfPerformance
      can :manage, Own
      can [:index, :create], Patron
      can [:show, :update, :destroy], Patron do |patron|
        patron.required_role_id <= 3
      end
      can :manage, PatronImportFile
      can :read, PatronImportResult
      can :manage, PatronRelationship
      can :read, PatronRelationshipType
      can :read, PatronType
      can :manage, PictureFile
      can :manage, Produce
      can :manage, ManifestationRelationship
      can :read, ManifestationRelationshipType
      can :manage, Realize
      can :manage, ResourceImportFile
      can :read, ResourceImportResult
      can :manage, SeriesHasManifestation
      can :manage, SeriesStatement
      can :manage, SeriesStatementRelationship
    when 'User'
      can :read, CarrierType
      can :read, ContentType
      can :read, Country
      can :read, Create
      can :read, Exemplify
      can :read, Extent
      can :read, Frequency
      can :read, FormOfWork
      can :index, Item
      can :show, Item do |item|
        item.required_role_id <= 2
      end
      can :read, Language
      can :read, License
      can [:read, :edit], Manifestation do |manifestation|
        manifestation.required_role_id <= 2
      end
      can :read, ManifestationRelationship
      can :read, ManifestationRelationshipType
      can :read, MediumOfPerformance
      can :read, Own
      can :index, Patron
      can :show, Patron do |patron|
        true if patron.required_role_id <= 2
      end
      can :read, PatronRelationship
      can :read, PatronRelationshipType
      can :index, PictureFile
      can :show, PictureFile do |picture_file|
        begin
          true if picture_file.picture_attachable.required_role_id <= 2
        rescue NoMethodError
          true
        end
      end
      can :show, User
      can :read, Produce
      can :read, Realize
      can :read, SeriesHasManifestation
      can :read, SeriesStatement
    else
      can :read, CarrierType
      can :read, ContentType
      can :read, Country
      can :read, Create
      can :read, Exemplify
      can :read, Extent
      can :read, Frequency
      can :read, FormOfWork
      can :read, Item
      can :read, Language
      can :read, License
      can :read, Manifestation do |manifestation|
        manifestation.required_role_id <= 1
      end
      can :read, ManifestationRelationship
      can :read, ManifestationRelationshipType
      can :read, MediumOfPerformance
      can :read, Own
      can :index, Patron
      can :show, Patron do |patron|
        true if patron.required_role_id <= 1
      end
      can :read, PatronRelationship
      can :read, PatronRelationshipType
      can :index, PictureFile
      can :show, PictureFile do |picture_file|
        begin
          true if picture_file.picture_attachable.required_role_id <= 2
        rescue NoMethodError
          true
        end
      end
      can :show, User
      can :read, Produce
      can :read, Realize
      can :read, SeriesHasManifestation
      can :read, SeriesStatement
    end
  end
end
