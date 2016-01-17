class TreePrintVisitor
  def initialize(dataSource, io)
    @indentation = 0
    @dataSource = dataSource
    @io = io
  end

  def nodeToStr(node)
    if (node.isRoot) then
      "ROOT"
    else
      "#{@dataSource.toString(node.incomingEdgeStartOffset, node.incomingEdgeEndOffset)}"
    end
  end

  def preVisit(node)
    @io.print "#{" "*@indentation}#{self.nodeToStr(node)}\n"
    @indentation += 1
    return true
  end

  def postVisit(node)
    @indentation -= 1
  end
end

class DfsTreePrintVisitor < TreePrintVisitor
  def nodeToStr(node)
    "#{node.dfsNumber} #{node.suffixOffset}, #{node.runTail.binaryTreeHeight}/#{node.runTail.dfsNumber} #{super}"
  end
end