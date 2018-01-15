class RentalModification
  attr_reader :delta_actions

  def initialize(rental, params = {})
    @id = params[:id]
    @rental = rental
    @changes = params
  end

  def compute_modifs
    @old_actions = @rental.actions
    @rental.update(@changes)
    @rental.compute_rental_price
    @delta_actions = @old_actions.zip(@rental.actions).map do |old, new|
      amount = old.amount - new.amount
      type = if amount < 0
               new.who == "driver" ? "debit" : "credit"
             else
               new.who == "driver" ? "credit" : "debit"
             end
      RentalAction.new(new.who, type, amount.abs)
    end
  end

  def to_h
    {
        id: @id,
        rental_id: @rental.id,
        actions: @delta_actions.collect { |a| a.to_h }
    }
  end
end