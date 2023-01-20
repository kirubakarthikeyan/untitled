class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> {true}

  def health
    head 200, content_type: "text/html"
  end

  protected

    def not_found!
      raise ActionController::RoutingError.new('Not Found')
    end
end
