module SalesEngine
  class Transaction
    attr_accessor :id, :invoice_id, :credit_card_number,
                  :credit_card_expiration_date, :result, :created_at,
                  :updated_at

    TRANSACTION_ATTS = [
     "id",
     "invoice_id",
     "credit_card_number",
     "credit_card_expiration_date",
     "result"
     ]

    def initialize(attrs)
      if attrs[:id]
        self.id = attrs[:id].to_i
      else
        self.id = (SalesEngine::Database.instance.invoice_list.size + 1).to_i
      end
      self.invoice_id = attrs[:invoice_id].to_i
      self.credit_card_number = attrs[:credit_card_number]
      self.credit_card_expiration_date = attrs[:credit_card_expiration_date]
      self.result = attrs[:result]
      if attrs[:created_at]
        self.created_at = Date.parse(attrs[:created_at])
      else
        self.created_at = Date.today
      end
      if attrs[:updated_at]
        self.updated_at = Date.parse(attrs[:updated_at])
      else
        self.updated_at = Date.today
      end
      store_result_in_invoice

      SalesEngine::Database.instance.transaction_list << self
      SalesEngine::Database.instance.transaction_id_hash[ self.id ] = self
    end

    def self.attributes_for_finders
      TRANSACTION_ATTS
    end

    def store_result_in_invoice
      return 0 if invoice.nil?
      if self.result == "success"
        invoice.result = true
      else
        invoice.result = false unless invoice.result
      end
    end

    extend SalesEngine::DynamicFinder

    def self.create(attrs)
      transaction = self.new( { :invoice_id => attrs[:invoice_id],
        :credit_card_number => attrs[:credit_card_number],
        :credit_card_expiration_date => attrs[:credit_card_expiration_date],
        :result => attrs[:result] })
      # SalesEngine::Database.instance.transaction_list << transaction
      transaction
    end

    def self.random
      transactions = SalesEngine::Database.instance.transaction_list
      random_id = Random.rand(transactions.size)
      self.find_by_id(random_id + 1)
    end

    # def self.find_by_id(id)
    #   SalesEngine::Database.instance.transaction_list.detect do |trans|
    #     trans if trans.id == id
    #   end
    # end

    def invoice
      SalesEngine::Invoice.find_by_id(self.invoice_id)
    end

    def is_successful?
      self.result == "success"
    end

    def self.find_all_by_invoice_id(invoice_id)
      SalesEngine::Database.instance.transaction_list.select do |trans|
        trans if trans.invoice_id == invoice_id
      end
    end

    def self.find_all_by_result(result)
      SalesEngine::Database.instance.transaction_list.select do |trans|
        trans if trans.result == result
      end
    end
  end
end