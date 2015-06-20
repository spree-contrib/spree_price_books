require 'spec_helper'

describe Spree::OrderContents do
  let(:order) { Spree::Order.create }
  let(:variant) { create(:variant) }

  subject { described_class.new(order) }

  context "#add" do
    context 'given quantity is not explicitly provided' do
      it 'should add one line item' do
        line_item = subject.add(variant, nil, {currency: 'USD'})
        line_item.quantity.should == 0
        order.line_items.size.should == 1
      end
    end

    it 'should add line item if one does not exist' do
      line_item = subject.add(variant, 1, {currency: 'USD'})
      line_item.quantity.should == 1
      order.line_items.size.should == 1
    end

    it 'should update line item if one exists' do
      subject.add(variant, 1, {currency: 'USD'})
      line_item = subject.add(variant, 1, {currency: 'USD'})
      line_item.quantity.should == 2
      order.line_items.size.should == 1
    end

    it "should update order totals" do
      order.item_total.to_f.should == 0.00
      order.total.to_f.should == 0.00

      subject.add(variant, 1, {currency: 'USD'})

      order.item_total.to_f.should == 19.99
      order.total.to_f.should == 19.99
    end

    context "running promotions" do
      let(:promotion) { create(:promotion) }
      let(:calculator) { Spree::Calculator::FlatRate.new(:preferred_amount => 10) }

      shared_context "discount changes order total" do
        before { subject.add(variant, 1, {currency: 'USD'}) }
        it { expect(subject.order.total).not_to eq variant.price }
      end

      context "one active order promotion" do
        let!(:action) { Spree::Promotion::Actions::CreateAdjustment.create(promotion: promotion, calculator: calculator) }

        it "creates valid discount on order" do
          subject.add(variant, 1, {currency: 'USD'})
          expect(subject.order.adjustments.to_a.sum(&:amount)).not_to eq 0
        end

        include_context "discount changes order total"
      end

      context "one active line item promotion" do
        let!(:action) { Spree::Promotion::Actions::CreateItemAdjustments.create(promotion: promotion, calculator: calculator) }

        it "creates valid discount on order" do
          subject.add(variant, 1, {currency: 'USD'})
          expect(subject.order.line_item_adjustments.to_a.sum(&:amount)).not_to eq 0
        end

        include_context "discount changes order total"
      end
    end

  end
end
