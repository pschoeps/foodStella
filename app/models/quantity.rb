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

	def convert_to_ounces()
		oz = 0
		a = self.amount
		u = self.unit.to_i

		whole = 0.0
		if a.include?(' ')
			whole = a.split(' ')[0].to_f
			a = a.split(' ')[1]
		end

		if a.include?('/')
			a = a.split('/')[0].to_f / a.split('/')[1].to_f
		end

		oz = a.to_f

		if whole != 0
			oz += whole
		end

		ratio = 1
		if u == 1
			ratio = 8
		elsif u == 3
			ratio = 0.166667
		elsif u == 4
			ratio = 0.5
		elsif u == 5
			raito = 0.013
		end
		oz *= ratio

		oz
	end
end
