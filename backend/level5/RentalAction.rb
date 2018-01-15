class RentalAction
  def initialize(who, type, amount)
    @who = who
    @type = type
    @amount = amount
  end

  def to_h
    {
        who: @who,
        type: @type,
        amount: @amount
    }
  end
end