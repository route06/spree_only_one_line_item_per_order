module SpreeOnlyOneLineItemPerOrder::Api::V2::Storefront::CartControllerDecorator
  def set_quantity
    render json: { error: "Unprocessable entity." }, status: 422
  end
end

Spree::Api::V2::Storefront::CartController.prepend(SpreeOnlyOneLineItemPerOrder::Api::V2::Storefront::CartControllerDecorator) unless Spree::Api::V2::Storefront::CartController.included_modules.include?(SpreeOnlyOneLineItemPerOrder::Api::V2::Storefront::CartControllerDecorator)
