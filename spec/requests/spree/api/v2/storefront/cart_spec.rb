# Derived from https://github.com/spree/spree/blob/v4.3.0/api/spec/requests/spree/api/v2/storefront/cart_spec.rb

require 'spec_helper'

describe 'API V2 Storefront Cart Spec', type: :request do
  let!(:store) { Spree::Store.default }
  let(:currency) { store.default_currency }
  let(:user)  { create(:user) }
  let(:order) { create(:order, user: user, store: store, currency: currency) }
  let(:product) { create(:product, stores: [store]) }
  let(:variant) { create(:variant, product: product) }

  include_context 'API v2 tokens'

  describe 'cart#add_item' do
    let(:options) { {} }
    let(:params) { { variant_id: variant.id, quantity: 1, options: options, include: 'variants' } }
    let(:execute) { post '/api/v2/storefront/cart/add_item', params: params, headers: headers }

    shared_examples 'adds item' do
      before { execute }

      it_behaves_like 'returns 200 HTTP status'
      it_behaves_like 'returns valid cart JSON'

      it 'with success' do
        order.reload
        expect(order.line_items.count).to eq(1)
        expect(order.line_items.last.variant).to eq(variant)
        expect(order.line_items.last.quantity).to eq(1)
        expect(json_response['included']).to include(have_type('variant').and(have_id(variant.id.to_s)))
      end
    end

    shared_examples 'doesnt add item due to already non-empty cart' do
      before { execute }

      it_behaves_like 'returns 422 HTTP status'

      it 'with failure' do
        order.reload
        expect(order.line_items.count).to eq(1)
        expect(json_response[:error]).to a_string_ending_with('is already in cart')
      end
    end

    shared_examples 'doesnt add item with quantity unnavailble' do
      before do
        variant.stock_items.first.update(backorderable: false)
        variant.stock_items.first.update_column(:count_on_hand, 0)
        params[:quantity] = 1
        execute
      end

      it_behaves_like 'returns 422 HTTP status'

      it 'returns an error' do
        expect(json_response[:error]).to eq("Quantity selected of \"#{variant.name} (#{variant.options_text})\" is not available.")
      end
    end

    shared_examples 'doesnt add item with quantity 2+' do
      before do
        variant.stock_items.first.update(backorderable: true)
        params[:quantity] = 2
        execute
      end

      it_behaves_like 'returns 422 HTTP status'

      it 'returns an error' do
        expect(json_response[:error]).to eq("line_item quantity allowed only 1")
      end
    end

    shared_examples 'doesnt add item from different store' do
      before do
        variant.product.stores = [create(:store)]
        execute
      end

      it_behaves_like 'returns 404 HTTP status'

      it 'returns an error' do
        expect(json_response[:error]).to eq('The resource you were looking for could not be found.')
      end
    end

    shared_examples 'doesnt add non-existing item' do
      before do
        variant.destroy
        execute
      end

      it_behaves_like 'returns 404 HTTP status'

      it 'returns an error' do
        expect(json_response[:error]).to eq('The resource you were looking for could not be found.')
      end
    end

    context 'as a signed in user' do
      include_context 'creates order with line item'

      it_behaves_like 'doesnt add item due to already non-empty cart'

      context 'with existing order' do
        before { order.line_items.destroy_all }
        it_behaves_like 'adds item'
        it_behaves_like 'doesnt add item with quantity unnavailble'
        it_behaves_like 'doesnt add item with quantity 2+'
        it_behaves_like 'doesnt add item from different store'
        it_behaves_like 'doesnt add non-existing item'
      end

      it_behaves_like 'no current order'
    end

    context 'as a guest user' do
      include_context 'creates guest order with guest token'

      it_behaves_like 'doesnt add item due to already non-empty cart'

      context 'with existing order' do
        before { order.line_items.destroy_all }
        it_behaves_like 'adds item'
        it_behaves_like 'doesnt add item with quantity unnavailble'
        it_behaves_like 'doesnt add item with quantity 2+'
        it_behaves_like 'doesnt add item from different store'
        it_behaves_like 'doesnt add non-existing item'
      end

      it_behaves_like 'no current order'
    end
  end

  describe 'cart#set_quantity' do
    let(:line_item) { create(:line_item, order: order) }
    let(:params) { { order: order, line_item_id: line_item.id, quantity: 1 } }
    let(:execute) { patch '/api/v2/storefront/cart/set_quantity', params: params, headers: headers }

    shared_examples 'unprocessable entity' do
      it_behaves_like 'returns 422 HTTP status'

      it 'returns an error' do
        expect(json_response[:error]).to eq('Unprocessable entity.')
      end
    end

    shared_examples 'set quantity' do
      context 'quantity not passed' do
        before do
          params[:quantity] = nil
          execute
        end

        it_behaves_like 'unprocessable entity'
      end

      it_behaves_like 'no current order'
    end

    context 'as a guest user' do
      include_context 'creates guest order with guest token'

      it_behaves_like 'set quantity'
    end

    context 'as a signed in user' do
      include_context 'creates order with line item'

      it_behaves_like 'set quantity'
    end
  end
end
