module SalesEngine
  class InvoiceItem
    attr_accessor :id, :item_id, :invoice_id, :quantity, :unit_price, :created_at, :updated_at, :date

    def initialize(attributes)
      self.id = attributes[:id]
      self.item_id = attributes[:item_id]
      self.invoice_id = attributes[:invoice_id]
      self.quantity =   BigDecimal.new(attributes[:quantity])
      self.unit_price = BigDecimal.new(attributes[:unit_price])
      self.created_at = DateTime.parse(attributes[:created_at]) if attributes[:created_at]
      self.updated_at = DateTime.parse(attributes[:updated_at]) if attributes[:updated_at]
    end

    def self.total_revenue
      total_revenue = BigDecimal.new("0")
      data = SalesEngine::Database.instance.invoice_item_list
      data.each do |i_i|
        total_revenue += i_i.quantity * i_i.unit_price
      end
      total_revenue
    end

    def self.total_revenue_by_att(att, param)
      total_revenue = BigDecimal.new("0")
      results = send(("find_all_by_" + att).to_sym, param)
      results.each do |i_i|
        total_revenue += i_i.quantity * i_i.unit_price
      end
      total_revenue
    end

    # def self.total_revenue_by_invoice_ids(invoice_ids)
    #   total_revenue = BigDecimal.new("0")
    #   data = invoice_ids.collect { |invoice_id| find_all_by_invoice_id(invoice_id) }
    #   data.each do |i_i|
    #     total_revenue += i_i.quantity * i_i.unit_price
    #   end
    #   total_revenue
    # end

    # def self.total_revenue_by_date(date)
    #   total_revenue = BigDecimal.new("0")
    #   data = .collect { |invoice| find_all_by_date(date) }
    #   data.each do |i_i|
    #     total_revenue += i_i.quantity * i_i.unit_price
    #   end
    #   total_revenue
    # end

    def self.find_all_by_invoice_id(invoice_id)
      SalesEngine::Database.instance.invoice_item_list.select do |i_i|
        i_i if i_i.invoice_id == invoice_id
      end
    end

    def self.find_all_by_date(date)
      date = Date.parse(date) if date.kind_of? String
      SalesEngine::Database.instance.invoice_item_list.select do |i_i|
        dt = i_i.created_at
        i_i if date == Date.new(dt.year, dt.mon, dt.mday)
      end
    end
  end
end