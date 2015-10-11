class TreePrintVisitor
  def initialize(dataSource, io)
    @indentation = 0
    @dataSource = dataSource
    @io = io
  end

  def preVisit(node)
    if (node.isRoot) then
      @io.print "ROOT\n"
    else
      @io.print "#{" "*@indentation}#{@dataSource.toString(node.incomingEdgeStartOffset, node.incomingEdgeEndOffset)}\n"
    end
    @indentation += 1
    return true
  end

  def postVisit(node)
    @indentation -= 1
  end
end