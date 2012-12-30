class Integer
  def is_prime?
    2.upto(self-1) { |num| return false if self % num == 0 }
    true
  end

  def prime_divisors
    pr_divisors = []
    2.upto(abs) do |num|
      if abs % num == 0 && num.is_prime?
        pr_divisors << num
      end
    end
    pr_divisors
  end
end

class Range
  def fizzbuzz
    collect do |elem|
      if elem % 15 == 0 then :fizzbuzz
      elsif elem % 3 == 0 then :fizz
      elsif elem % 5 == 0 then :buzz
      else elem
      end
    end
  end
end

class Hash
  def group_values
    groups = Hash.new { |hash, key| hash[key] = [] }
    each {|key, value| groups[value] << key}
    groups
  end
end

class Array
  def densities
    collect { |elem| count(elem) }
  end
end