class TreePrintVisitor
  def initialize(dataSource)
    @indentation = 0
    @dataSource = dataSource
  end

  def preVisit(node)
    if (node.isRoot) then
      print "ROOT\n"
    else
      print "#{" "*@indentation}#{@dataSource.toString(node.incomingEdgeStartOffset, node.incomingEdgeEndOffset)}\n"
    end
    @indentation += 1
    return true
  end

  def postVisit(node)
    @indentation -= 1
  end
end