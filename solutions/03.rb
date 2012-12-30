class Expr
  def self.build(tree)
    first, *rest = *tree
        rest.map! { |item| item.is_a?(Array) ? build(item) : item }
    case first
      when :number   then Number.new(rest.last)
      when :variable then Variable.new(rest.last)
      when :+        then Addition.new(rest)
      when :*        then Multiplication.new(rest)
      when :-        then Negation.new(rest.last)
      when :sin      then Sine.new(rest.last)
      when :cos      then Cosine.new(rest.last)
    end
  end
end

class Unary < Expr
  attr_accessor :argument

  def initialize(argument)
    @argument = argument
  end

  def argument_simplified
    @argument_simplified ||= @argument.simplify
  end

  def ==(other)
    self.class == other.class && @argument == other.argument
  end

  def exact?
    @argument.exact?
  end

  def simplify
    self
  end
end

class Binary < Expr
  attr_accessor :left
  attr_accessor :right

  def initialize(argument)
    @left, @right = *argument
  end

  def left_simplified
    @left_simplified ||= @left.simplify
  end

  def right_simplified
    @right_simplified ||= @right.simplify
  end

  def ==(other)
    self.class == other.class && @left == other.left && @right == other.right
  end

  def exact?
    @left.exact? && @right.exact?
  end
end

class Number < Unary
  def evaluate(environment = {})
    @argument
  end

  def exact?
    true
  end

  def derive(variable)
    Number.new(0).simplify
  end
end

class Addition < Binary
  def evaluate(environment = {})
    @left.evaluate(environment) + @right.evaluate(environment)
  end

  def simplify
    if right_simplified == Number.new(0)
      left_simplified
    elsif left_simplified == Number.new(0)
      right_simplified
    elsif @left.exact? && @right.exact?
      Number.new(evaluate(environment = {}))
    else
      self
    end
  end

  def derive(variable)
    Addition.new([@left.derive(variable), @right.derive(variable)]).simplify
  end
end

class Multiplication < Binary
  def evaluate(environment = {})
    left.evaluate(environment) * right.evaluate(environment)
  end

  def simplify
    if right_simplified == Number.new(0) || left_simplified == Number.new(0)
      Number.new(0)
    elsif right_simplified == Number.new(1)
      left_simplified
    elsif left_simplified == Number.new(1)
      right_simplified
    elsif @left.exact? && @right.exact?
      Number.new(evaluate(environment = {}))
    else
      self
    end
  end

  def derive(variable)
    Addition.new([Multiplication.new([@left.derive(variable), @right]).simplify,
      Multiplication.new([@left, @right.derive(variable)]).simplify])
  end
end

class Variable < Unary
  def evaluate(environment = {})
    if environment[@argument]
      environment[@argument]
    else
      fail
    end
  end

  def exact?
    false
  end

  def derive(variable)
    if variable == @argument
      Number.new(1).simplify
    else
      Number.new(0).simplify
    end
  end
end

class Negation < Unary
  def evaluate(environment = {})
    -@argument.evaluate(environment)
  end
end

class Sine < Unary
  def evaluate(environment = {})
    Math.sin(@argument.evaluate(environment))
  end

  def simplify
    if argument_simplified == Number.new(0)
      Number.new(0)
    elsif @argument.exact?
      evaluate(environment = {})
    else
      self
    end
  end

  def derive(variable)
    Multiplication.new([@argument.derive(variable), Cosine.new(@argument)]).simplify
  end
end

class Cosine < Unary
  def evaluate(environment = {})
    Math.cos(@argument.evaluate(environment))
  end

  def simplify
    if argument_simplified == Number.new(1)
      Number.new(0)
    elsif @argument.exact?
      evaluate(environment = {})
    else
      self
    end
  end

  def derive(variable)
    Multiplication.new([@argument.derive(variable), Negation.new(Sine.new(@argument))]).simplify
  end
end