# frozen_string_literal: true

class LiquidHandler
  attr_accessor :controller, :path, :assigns, :locals, :layout

  def initialize(*args)
    @path = args.at(0)
    @assigns ||= args.at(1)
    @locals ||= args.at(2)

    opts = if args.last.class == Hash
      args.last
    else
      {}
    end

    @controller = opts[:controller] || ApplicationController.new
    @layout = opts[:layout] || false
  end
end
