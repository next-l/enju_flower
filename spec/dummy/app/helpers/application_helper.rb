module ApplicationHelper
  include EnjuLeaf::EnjuLeafHelper
  include EnjuBiblio::BiblioHelper if defined?(EnjuBiblio)
  if defined?(EnjuManifestationViewer)
    include EnjuManifestationViewer::BookJacketHelper
    include EnjuManifestationViewer::ManifestationViewerHelper
  end
end
