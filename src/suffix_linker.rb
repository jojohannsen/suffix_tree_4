class SuffixLinker
  def initialize()
    @nodeNeedingSuffixLink = nil
  end

  def update(location)
    if ((@nodeNeedingSuffixLink != nil) && location.onNode) then
      @nodeNeedingSuffixLink.suffixLink = location.node
      @nodeNeedingSuffixLink = nil
    end
  end

  def nodeNeedingSuffixLink(node)
    if (@nodeNeedingSuffixLink != nil) then
      @nodeNeedingSuffixLink.suffixLink = node
    end
    @nodeNeedingSuffixLink = node
  end
end