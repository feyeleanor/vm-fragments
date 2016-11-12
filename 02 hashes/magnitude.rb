# lifted from http://stackoverflow.com/a/539432

largest_known_fixnum = 1
smallest_known_bignum = nil

until smallest_known_bignum == largest_known_fixnum + 1
	if smallest_known_bignum.nil?
		next_number_to_try = largest_known_fixnum * 1000
	else
		# Geometric mean would be more efficient, but more risky
		next_number_to_try = (smallest_known_bignum + largest_known_fixnum) / 2
	end

	case next_number_to_try
    when Bignum
		smallest_known_bignum = next_number_to_try
	when Fixnum
		largest_known_fixnum = next_number_to_try
	end
end

Fixnum::MAX = largest_known_fixnum
Bignum::MIN = smallest_known_bignum