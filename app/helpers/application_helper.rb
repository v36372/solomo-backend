module ApplicationHelper
  def vietnamese_currency(number)
    number_to_currency(number.to_i, unit: "đ", separator: ".", delimiter: ",", format: "%n %u", precision: 0)
  end
end
