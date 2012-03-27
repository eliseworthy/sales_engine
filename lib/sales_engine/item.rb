module SalesEngine
  class Item
    attr_accessor :id, :name, :description, :unit_price, :merchant_id, :created_at, :updated_at

    ITEM_ATTS = [
      "id",
      "name",
      "description",
      "unit_price",
      "merchant_id",
      "created_at",
      "updated_at"
      ]

    def initialize(attributes)
      self.id = attributes[:id]
      self.name = attributes[:name]
      self.description = attributes[:description]
      self.unit_price = attributes[:unit_price]
      self.merchant_id = attributes[:merchant_id]
      self.created_at = attributes[:created_at]
      self.updated_at = attributes[:updated_at]
    end

    ITEM_ATTS.each do |att|
      define_singleton_method ("find_by_" + att).to_sym do |param|
        SalesEngine::Database.instance.item_list.detect do |item|
          item.send(att.to_sym).to_s.downcase == param.to_s.downcase
        end
      end
    end

    ITEM_ATTS.each do |att|
      define_singleton_method ("find_all_by_" + att).to_sym do |param|
        SalesEngine::Database.instance.item_list.select do |item|
          item if item.send(att.to_sym).to_s.downcase == param.to_s.downcase
        end
      end
    end

    def invoice_items
      SalesEngine::InvoiceItem.find_all_by_item_id(self.id)
    end

    def merchant
      SalesEngine::Merchant.find_by_id(self.merchant_id)
    end

    def self.most_revenue(num)

      successful_invoice_items = SalesEngine::InvoiceItem.successful_invoice_items
      item_data = { }

      successful_invoice_items.each do |invoice_item|
        item_data[ invoice_item.item_id.to_sym ] ||= 0
        item_data[ invoice_item.item_id.to_sym ] += invoice_item.quantity * invoice_item.unit_price
      end

      item_data = item_data.sort_by {|item_id, revenue| -revenue }

      item_data[0..(num-1)].collect do |item_id, revenue|
        SalesEngine::Item.find_by_id(item_id)
      end
    end

    def self.most_items(num)
      successful_invoice_items = SalesEngine::InvoiceItem.successful_invoice_items
      item_data = { }

      successful_invoice_items.each do |invoice_item|
        item_data[ invoice_item.item_id.to_sym ] ||= 0
        item_data[ invoice_item.item_id.to_sym ] += invoice_item.quantity 
      end

      item_data = item_data.sort_by {|item_id, quantity| -quantity }

      item_data[0..(num-1)].collect do |item_id, quantity|
        SalesEngine::Item.find_by_id(item_id)
      end
    end

    def best_day
      invoice_items = SalesEngine::InvoiceItem.find_all_by_item_id(self.id)
      item_data = { }

      invoice_items.each do |invoice_item|
        item_data[ invoice_item.created_at.strftime("%Y/%m/%d") ] ||= 0
        item_data[ invoice_item.created_at.strftime("%Y/%m/%d") ] += invoice_item.quantity 
      end

      item_data = item_data.sort_by {|day, quantity| -quantity }
      puts item_data.inspect
      Date.parse(item_data.first[0])

      #find all invoice items with this item id
      #sort them by date
      #add up quantities for each date
      #return the date that has the highest quantity
    end
  end
end