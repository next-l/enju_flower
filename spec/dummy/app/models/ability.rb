#module EnjuBiblio
  class Ability
    include CanCan::Ability

    def initialize(user, ip_address = '0.0.0.0')
      case user.try(:role).try(:name)
      when 'Administrator'
        can [:read, :create, :update], CarrierType
        can [:destroy, :delete], CarrierType do |carrier_type|
          true unless carrier_type.manifestations.exists?
        end if LibraryGroup.site_config.network_access_allowed?(ip_address)
        can [:read, :create, :update], Item
        can [:destroy, :delete], Item do |item|
          item.removable?
        end
        can [:read, :create, :update], Manifestation
        can [:destroy, :delete], Manifestation do |manifestation|
          manifestation.items.empty? and !manifestation.series_master?
        end
        can :manage, [
          Create,
          CreateType,
          Donate,
          Exemplify,
          ImportRequest,
          ManifestationRelationship,
          ManifestationRelationshipType,
          Own,
          Patron,
          PatronImportFile,
          PatronRelationship,
          PatronRelationshipType,
          PictureFile,
          Produce,
          ProduceType,
          Realize,
          RealizeType,
          ResourceImportFile,
          SeriesStatement
        ]
        can :update, [
          ContentType,
          Country,
          Extent,
          Frequency,
          FormOfWork,
          Language,
          License,
          MediumOfPerformance,
          PatronType,
          RequestStatusType,
          RequestType
        ] if LibraryGroup.site_config.network_access_allowed?(ip_address)
        can :read, [
          CarrierType,
          ContentType,
          Country,
          Extent,
          Frequency,
          FormOfWork,
          Language,
          License,
          MediumOfPerformance,
          PatronImportResult,
          PatronType,
          RequestStatusType,
          RequestType,
          ResourceImportResult
        ]
      when 'Librarian'
        can :manage, Item
        can :index, Manifestation
        can [:show, :create, :update], Manifestation
        can [:destroy, :delete], Manifestation do |manifestation|
          manifestation.items.empty? and !manifestation.series_master?
        end
        can [:index, :create], Patron
        can :show, Patron do |patron|
          patron.required_role_id <= 3
        end
        can [:update, :destroy, :delete], Patron do |patron|
          !patron.user.try(:has_role?, 'Librarian') and patron.required_role_id <= 3
        end
        can :manage, [
          Create,
          Donate,
          Exemplify,
          ImportRequest,
          ManifestationRelationship,
          Own,
          PatronImportFile,
          PatronRelationship,
          PictureFile,
          Produce,
          Realize,
          ResourceImportFile,
          SeriesStatement
        ]
        can :read, [
          CarrierType,
          ContentType,
          Country,
          Extent,
          Frequency,
          FormOfWork,
          Language,
          License,
          ManifestationRelationshipType,
          PatronImportResult,
          PatronRelationshipType,
          PatronType,
          RequestStatusType,
          RequestType,
          ResourceImportResult,
          MediumOfPerformance
        ]
      when 'User'
        can :index, Item
        can :show, Item do |item|
          item.required_role_id <= 2
        end
        can :index, Manifestation
        can [:show, :edit], Manifestation do |manifestation|
          manifestation.required_role_id <= 2
        end
        can :index, Patron
        can :update, Patron do |patron|
          patron.user == user
        end
        can :show, Patron do |patron|
          #if patron.user == user
          #  true
          #elsif patron.user != user
            true if patron.required_role_id <= 2 #name == 'Administrator'
          #end
        end
        can :index, PictureFile
        can :show, PictureFile do |picture_file|
          begin
            true if picture_file.picture_attachable.required_role_id <= 2
          rescue NoMethodError
            true
          end
        end
        can :read, [
          CarrierType,
          ContentType,
          Country,
          Create,
          Exemplify,
          Extent,
          Frequency,
          FormOfWork,
          Language,
          License,
          ManifestationRelationship,
          ManifestationRelationshipType,
          MediumOfPerformance,
          Own,
          PatronRelationship,
          PatronRelationshipType,
          Produce,
          Realize,
          SeriesStatement
        ]
      else
        can :index, Manifestation
        can :show, Manifestation do |manifestation|
          manifestation.required_role_id == 1
        end
        can :index, Patron
        can :show, Patron do |patron|
          patron.required_role_id == 1 #name == 'Guest'
        end
        can :read, [
          CarrierType,
          ContentType,
          Country,
          Create,
          Exemplify,
          Extent,
          Frequency,
          FormOfWork,
          Item,
          Language,
          License,
          ManifestationRelationship,
          ManifestationRelationshipType,
          MediumOfPerformance,
          Own,
          PatronRelationship,
          PatronRelationshipType,
          PictureFile,
          Produce,
          Realize,
          SeriesStatement
        ]
      end
    end
  end
#end
