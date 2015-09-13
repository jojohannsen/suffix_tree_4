class NodeCountVisitor
  attr_reader :count

  def initialize
    @count = 0
  end

  def preVisit(node)
    @count += 1
  end

  def postVisit(node)
    # do nothing
  end
end