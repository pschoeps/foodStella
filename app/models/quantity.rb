class Quantity < ActiveRecord::Base
  belongs_to :recipe
  belongs_to :ingredient

  accepts_nested_attributes_for :ingredient

	def get_unit(unit, amount)
		string = case unit
	          when "1"
	            if amount.to_i > 1
	            	"Cups"
	            else
	            	"Cup"
	            end
	          when "2"
	            "Oz."
	          when "3"
	            "Tsp."
	          when "4"
	           	"Tbsp."
	          when "5"
	           	if amount.to_i > 1
	           		"Pinches"
	           	else
	           		"Pinch"
	           	end
	         else
	         	""
	         end
		string
	end
end
