require 'strscan'
$KCODE='UTF8'

module Chimp
  class Parser
    class OpenTag
      attr_reader :type, :level
      attr_accessor :data, :close, :userdata
      def initialize(type,level)
        @type = type
        @data = nil
        @close = -1
        @userdata = nil
        @level = level
      end
    end  
    class CloseTag
      attr_reader :type, :open, :position_in_markup, :level
      def initialize(type,open,position_in_markup,level)
        @type = type
        @open = open
        @position_in_markup = position_in_markup
        @level = level
      end
    end
      
    class TagEvent < Exception; end
    class TagSkipEvent < Exception; end
    class TagBackEvent < Exception; end
    class TagContentSkipEvent < Exception; end
    
    class Output
      def finish_prepare
      end
      def finish_output
        ""
      end
      def string(data)
        data
      end
    end 

    class Grammar
      attr_reader :tree # a list which pretends to be a tree :-)

      class Pattern
        attr_reader :type, :pstart, :pend, :bol
        def initialize(type, pstart, pend, bol=false)
          @type = type
          @pstart = pstart
          @pend = pend
          @bol = bol
        end
      end

      def initialize
        @tree = []
      end
      
      def Grammar.parse(text)
        new.parse(text)
      end

      def parse(text)
        gparse(text,self.class::constants.include?("ROOT") ? self.class::ROOT : [])
        self
      end

      def inspect
        out = ""; indent = ""
        @tree.each do |c|
          indent = indent[0..-3] if c.class == CloseTag
          out << indent + c.inspect + "\n"
          indent << "  " if c.class == OpenTag
        end
        out
      end  
      
      def output(output)
        out = ''; i = 0
        puts @tree.length
        while @tree.length > i
          c = @tree[i]
          begin
            met = case
              when c.class == String
                data = c
                output.method("string")
              when c.class == OpenTag
                data = c.data
                output.method("mO" + c.type)
              when c.class == CloseTag
                data = @tree[c.open].data
                output.method("mC" + c.type)
            end
            out << case met.arity
              when 1: met.call(data) 
              when 2: met.call(c,data) 
              when 4: met.call(c,i,@tree,data)
              else
                ""
            end.to_s
            i += 1
          rescue NameError
            i += 1
          rescue TagSkipEvent
            i = c.close + 1 if c.class == OpenTag
          rescue TagContentSkipEvent
            i = c.close if c.class == OpenTag
          rescue TagBackEvent
            i = c.open if c.class == CloseTag
          rescue => e  
            p e.message
            p "ergo"
            exit
          end
        end 
        out << output.method("finish_output").call
        out
      end  
      
      def prepare(output)
        @tree.each do |c|
          begin
            output.method("mP" + c.type).call(c.data) if c.class == OpenTag
          rescue NameError
          rescue TagSkipEvent
          rescue TagContentSkipEvent
          rescue TagBackEvent
          end
        end 
        output.method("finish_prepare").call
        self 
      end  

      def gparse(text,grammar,position_in_markup=0,level=0)
        return if text.nil?
        s = StringScanner.new(text)
        while !s.eos?
          success = false
          grammar.each do |pat|
            if s.match?(pat.pstart)
              pos = s.pos
              bol = (pos == 0) ? true : s.string[pos-1] == 10
              ts  = s.scan(pat.pstart)
              te = if s.eos?
                "" =~ pat.pend ? "" : nil
              else  
                (pat.bol && !bol) ? nil : s.scan_until(pat.pend)
              end

              if te.nil?
                s.pos = pos
              else
                ti = te.sub(pat.pend,"")
                te = te[ti.length..-1]
                @tree << ot = OpenTag.new(pat.type,level)
                tpos = @tree.length-1
                inner = begin
                  self.method("m" + pat.type).call(ts,ti,te)
                rescue NameError
                  ti
                rescue TagEvent
                  @tree.pop
                  s.pos = pos
                  next
                rescue TagSkipEvent  
                  @tree.pop
                  success = true
                  next
                end
                gparse(inner,self.class::constants.include?("G" + pat.type) ? self.class::const_get("G" + pat.type) : [],position_in_markup+pos+ts.length,level+1)
                @tree << CloseTag.new(pat.type,tpos,position_in_markup+s.pos,level)
                ot.close = @tree.length-1
                success = true
                break
              end  
            end  
          end  
          unless success
            if @tree.last.class == String
              @tree.last << s.getch
            else  
              @tree << s.getch
            end  
          end
        end  
      end

      private :gparse
    end  

  end  
end
