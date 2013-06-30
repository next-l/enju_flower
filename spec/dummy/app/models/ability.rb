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
          Agent,
          AgentImportFile,
          AgentRelationship,
          AgentRelationshipType,
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
          AgentType,
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
          AgentImportResult,
          AgentType,
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
        can [:index, :create], Agent
        can :show, Agent do |agent|
          agent.required_role_id <= 3
        end
        can [:update, :destroy, :delete], Agent do |agent|
          !agent.user.try(:has_role?, 'Librarian') and agent.required_role_id <= 3
        end
        can :manage, [
          Create,
          Donate,
          Exemplify,
          ImportRequest,
          ManifestationRelationship,
          Own,
          AgentImportFile,
          AgentRelationship,
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
          AgentImportResult,
          AgentRelationshipType,
          AgentType,
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
        can :index, Agent
        can :update, Agent do |agent|
          agent.user == user
        end
        can :show, Agent do |agent|
          #if agent.user == user
          #  true
          #elsif agent.user != user
            true if agent.required_role_id <= 2 #name == 'Administrator'
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
          AgentRelationship,
          AgentRelationshipType,
          Produce,
          Realize,
          SeriesStatement
        ]
      else
        can :index, Manifestation
        can :show, Manifestation do |manifestation|
          manifestation.required_role_id == 1
        end
        can :index, Agent
        can :show, Agent do |agent|
          agent.required_role_id == 1 #name == 'Guest'
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
          AgentRelationship,
          AgentRelationshipType,
          PictureFile,
          Produce,
          Realize,
          SeriesStatement
        ]
      end
    end
  end
#end
