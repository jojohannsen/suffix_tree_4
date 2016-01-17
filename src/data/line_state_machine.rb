require 'state_machine'

#
#  First pass at state machine for converting sequence of formatted lines into a different
#  set of word values, in this case "<N>, blank, |, blank, <footer title>" get converted
#  into [ "END_OF_PAGE", "<page number>", "<title as a single word>"]
#
class LineStateMachine
  def initialize
    @dataQueue = []
    super
  end

  def resetState(data)
    self.reset
    result = []
    result << @dataQueue
    result << data
    @dataQueue = []
    result.flatten
  end

  def process(line)
    data = line.split

    # we are looking for a blank, a pipe, or a page number
    if (data.length == 0) then
      if (self.foundBlank) then
        return []
      end
    end
    if (data.length == 1) then
      if (data[0] == "|") then
        if (self.foundPipe) then
          return []
        end
      end
      ival = data[0].to_i
      if (ival > 0) then
        if (self.foundN) then
          @potentialPageNumber = ival
          @dataQueue << data  # in case this really isn't it
          return []
        end
      end
    end

    # if we are looking for the title, the entire line is the title
    if (data.length > 0) then
      if (self.foundTitle) then
        @dataQueue = []
        return [ "END_OF_PAGE", "#{@potentialPageNumber}", "#{line}"]
      end
    end

    resetState(data)
  end

  state_machine :state, :initial => :lookingForN do
    event :foundN do
      transition :lookingForN => :lookingForFirstBlank
    end

    event :foundBlank do
      transition :lookingForFirstBlank => :lookingForPipe, :lookingForSecondBlank => :lookingForTitle
    end

    event :foundPipe do
      transition :lookingForPipe => :lookingForSecondBlank
    end

    event :foundTitle do
      transition :lookingForTitle => :lookingForN
    end

    event :reset do
      transition all => :lookingForN
    end
  end
end