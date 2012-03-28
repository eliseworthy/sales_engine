module SalesEngine
  require 'sales_engine/dynamic_finder'
  class Invoice
    INVOICE_ATTS = [
      "id",
      "customer_id",
      "merchant_id",
      "status",
      "created_at",
      "updated_at"
    ]

    attr_accessor :id, :customer_id, :merchant_id, :status,
                  :created_at, :updated_at

    def initialize(attributes)
      self.id = attributes[:id]
      self.customer_id = attributes[:customer_id]
      self.merchant_id = attributes[:merchant_id]
      self.status = attributes[:status]
      if attributes[:created_at]
        self.created_at = Time.parse(attributes[:created_at])
      end
      if attributes[:updated_at]
        self.updated_at = Time.parse(attributes[:updated_at])
      end
    end

    def self.attributes_for_finders
      INVOICE_ATTS
    end

    extend SalesEngine::DynamicFinder

    def transactions
      SalesEngine::Transaction.find_all_by_invoice_id(self.id)
    end

    def invoice_items
      SalesEngine::InvoiceItem.find_all_by_invoice_id(self.id)
    end

    def invoice_revenue
      revenue = BigDecimal.new("0.00")
      if self.is_successful?
        revenue = SalesEngine::InvoiceItem.total_revenue_by_invoice_id(self.id)
      end
      revenue
    end

    def customer
      SalesEngine::Customer.find_by_id(self.customer_id)
    end

    def items
      items = self.invoice_items.collect do |i_i|
        SalesEngine::Item.find_by_id(i_i.item_id)
      end
    end

    def is_successful?
      transactions = SalesEngine::Transaction.find_all_by_invoice_id(self.id)

      transactions.any? do |transaction|
        transaction.is_successful?
      end
    end

    def self.successful_invoices
      success_trans = SalesEngine::Transaction.find_all_by_result("success")
      success_trans.collect { |trans| find_by_id(trans.invoice_id) }
    end

    def self.pending
      SalesEngine::Database.instance.invoice_list - successful_invoices
    end

    def self.find_all_successful_invoices_by_date(date)
      successful_invoices.select do |i|
        dt = i.updated_at
        date = Time.parse(date) if date.kind_of? String
        i if date == Time.new(dt.year, dt.mon, dt.mday)
      end
    end

    # bad method

    def self.average_revenue
        SalesEngine::InvoiceItem.total_revenue / self.successful_invoices.size
    end

    #def self.average_revenue(*date)
    #   invoices = SalesEngine::Database.instance.invoice_list
      # puts SalesEngine::InvoiceItem.total_revenue.inspect
      # avg_rev = SalesEngine::InvoiceItem.total_revenue / invoices.size

      # avg_rev = avg_rev.to_f.round(2)

      #   #collect all the invoice ids that happened on date
      #     #call Invoice Item's find total_rev_by_att on each invoice id
      #     #sum all of them
      #     #divide the sum by all the invoices that happened on date
      #   total_rev = BigDecimal.new("0.00")
      #   date = Time.parse(date.first)
      #   inv_on_date = find_all_successful_invoices_by_date(date)
      #   inv_ids_on_date = inv_on_date.collect { |inv| inv.id }
      #   inv_ids_on_date.each do |inv_id|
      #     rev = SalesEngine::InvoiceItem.total_revenue_by_invoice_id(inv_id)
      #     total_rev += rev
      #   end

      #   return 0 if inv_on_date.empty?
      #   avg_rev = total_rev / inv_on_date.size
      #   SalesEngine::InvoiceItem.total_revenue(date) / find_all_by_date(date)

    # end

  end
end

