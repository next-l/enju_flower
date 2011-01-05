class Item < ActiveRecord::Base
  scope :for_checkout, :conditions => ['item_identifier IS NOT NULL']
  scope :not_for_checkout, :conditions => ['item_identifier IS NULL']
  scope :on_shelf, :conditions => ['shelf_id != 1']
  scope :on_web, :conditions => ['shelf_id = 1']
  has_one :exemplify
  has_one :manifestation, :through => :exemplify
  belongs_to :shelf
  belongs_to :circulation_status
  belongs_to :checkout_type
  has_many :item_has_use_restrictions, :dependent => :destroy
  has_many :use_restrictions, :through => :item_has_use_restrictions
  has_many :checkouts
  has_many :reserves
  has_many :reserved_patrons, :through => :reserves, :class_name => 'Patron'
  has_many :lending_policies, :dependent => :destroy
  has_one :barcode, :as => :barcodable, :dependent => :destroy

  def self.per_page
    10
  end

  def reservable?
    return false if ['Lost', 'Missing', 'Claimed Returned Or Never Borrowed'].include?(self.circulation_status.name)
    return false if self.item_identifier.blank?
    true
  end

  def rent?
    return true if self.checkouts.not_returned.detect{|checkout| checkout.item_id == self.id}
    false
  end

  def reserved_by_user?(user)
    if self.next_reservation
      return true if self.next_reservation.user == user
    end
    false
  end
end
