class InvoiceItem
  attr_accessor :id, :item_id, :invoice_id, :quantity, :unit_price, :created_at, :updated_at

  def initialize(attributes)
    self.id = attributes[:id]
    self.item_id = attributes[:item_id]
    self.invoice_id = attributes[:invoice_id]
    self.quantity = attributes[:quantity]
    self.unit_price = attributes[:unit_price]
    self.created_at = attributes[:created_at]
    self.updated_at = attributes[:updated_at]
  end
end