class Expr
  def self.build(tree)
    case tree.shift
      when :number   then Number.new tree.shift
      when :variable then Variable.new tree.shift
      when :+        then Expr.build(tree.shift) + Expr.build(tree.shift)
      when :*        then Expr.build(tree.shift) * Expr.build(tree.shift)
      when :-        then -Expr.build(tree.shift)
      when :sin      then Sine.new Expr.build(tree.shift)
      when :cos      then Cosine.new Expr.build(tree.shift)
    end
  end

  def +(other)
    Addition.new(self, other)
  end

  def -@
    Negation.new(self)
  end

  def *(other)
    Multiplication.new(self, other)
  end

  def derive(variable)
    derivative(variable).simplify
  end
end

class Unary < Expr
  attr_accessor :argument

  def initialize(argument)
    @argument = argument
  end

  def ==(other)
    self.class == other.class and @argument == other.argument
  end

  def exact?
    @argument.exact?
  end

  def simplify
    self
  end
end

class Binary < Expr
  attr_accessor :left, :right

  def initialize(left, right)
    @left, @right = left, right
  end

  def ==(other)
    self.class == other.class and @left == other.left and @right == other.right
  end

  def exact?
    @left.exact? and @right.exact?
  end
end

class Number < Unary
  def evaluate(env = {})
    @argument
  end

  def exact?
    true
  end

  def self.zero
    new 0
  end

  def self.one
    new 1
  end

  def derivative(variable)
    Number.zero
  end
end

class Addition < Binary
  def evaluate(env = {})
    @left.evaluate(env) + @right.evaluate(env)
  end

  def simplify
    if exact?
      Number.new(@left.evaluate + @right.evaluate)
    elsif @right.simplify == Number.zero
      @left.simplify
    elsif @left.simplify == Number.zero
      @right.simplify
    else
      @left.simplify + @right.simplify
    end
  end

  def derivative(variable)
    @left.derive(variable) + @right.derive(variable)
  end
end

class Multiplication < Binary
  def evaluate(env = {})
    @left.evaluate(env) * @right.evaluate(env)
  end

  def simplify
    if exact?
      Number.new(@left.evaluate * @right.evaluate)
    elsif @right.simplify == Number.zero or @left.simplify == Number.zero
      Number.zero
    elsif @right.simplify == Number.one
      @left.simplify
    elsif @left.simplify == Number.one
      @right.simplify
    else
      @left.simplify * @right.simplify
    end
  end

  def derivative(variable)
    @left.derive(variable) * @right + @left * @right.derive(variable)
  end
end

class Variable < Unary
  def evaluate(env = {})
    raise ArgumentError, "Missing argument" unless env[@argument]
    env[@argument]
  end

  def exact?
    false
  end

  def derivative(variable)
    if variable == @argument
      Number.one
    else
      Number.zero
    end
  end
end

class Negation < Unary
  def evaluate(env = {})
    -@argument.evaluate(env)
  end

  def simplify
    if @argument.exact?
      Number.new(@argument.evaluate)
    else
      Negation.new(@argument.simplify)
    end
   end

  def derivative(variable)
    -@argument.derive(variable)
  end
end

class Sine < Unary
  def evaluate(env = {})
    Math.sin(@argument.evaluate(env))
  end

  def simplify
    if @argument.simplify == Number.zero
      Number.zero
    elsif @argument.exact?
      Number.new(@argument.evaluate)
    else
      Sine.new(@argument.simplify)
    end
  end

  def derivative(variable)
    @argument.derive(variable) * Cosine.new(@argument)
  end
end

class Cosine < Unary
  def evaluate(env = {})
    Math.cos(@argument.evaluate(env))
  end

  def simplify
    if @argument.simplify == Number.one
      Number.zero
    elsif @argument.exact?
      Number.new(@argument.evaluate)
    else
      Cosine.new(@argument.simplify)
    end
  end

  def derivative(variable)
    @argument.derive(variable) * (-Sine.new(@argument))
  end
end