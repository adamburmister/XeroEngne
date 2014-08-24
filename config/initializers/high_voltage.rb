HighVoltage.configure do |config|
  config.parent_engine = XeroEngine::Engine
  config.route_drawer = HighVoltage::RouteDrawers::Root
  config.home_page = 'home'
  config.layout = 'xero_engine/static_page'
end

XeroEngine::HighVoltage = HighVoltage
