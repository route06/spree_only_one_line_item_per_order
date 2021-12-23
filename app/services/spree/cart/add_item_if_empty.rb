module Spree
  module Cart
    class AddItemIfEmpty < AddItem
      private

      def add_to_line_item(order:, variant:, quantity: nil, options: {})
        options ||= {}
        quantity = options[:quantity] if options[:quantity]
        if quantity && quantity.to_i != 1
          return failure(order, "line_item quantity allowed only 1")
        end

        line_item = order.line_items.first
        if line_item
          return failure(order, "#{line_item.product&.name} is already in cart")
        end

        super
      end
    end
  end
end
