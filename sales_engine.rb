$LOAD_PATH.unshift('./')
$LOAD_PATH.unshift('./lib/sales_engine')

require 'csv_loader'
require 'bigdecimal'
require 'date'

module SalesEngine
  def self.startup
    SalesEngine::CSVLoader.new
  end
end

SalesEngine.startup

# SE.load_invoices
# puts SE.invoices