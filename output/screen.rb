require 'ncurses'

module Chimp
  class Parser

    class Screen < Output
      #### Optional functions called when a tree is tranformed to output ####
      #### mO + patternname for opening tags ####
      #### mC + patternname for closing tags ####
      
      def initialize()
        @scounter = @ccounter = 0
        @what = ''
        Ncurses::initscr
        if Ncurses::has_colors?
          bg = Ncurses::COLOR_BLACK 
          Ncurses::start_color 
          if Ncurses::respond_to?("use_default_colors")
            if Ncurses::use_default_colors == Ncurses::OK
              bg = -1 
            end 
          end
          Ncurses::init_pair(1, Ncurses::COLOR_RED, bg);
          Ncurses::init_pair(2, Ncurses::COLOR_BLUE, bg);
        end
        Ncurses::cbreak
        Ncurses::noecho
        Ncurses::nonl
        Ncurses::curs_set(0)
        @win = Ncurses::stdscr
        @win::intrflush(false)
        Ncurses.keypad(@win, true)
      end

      def finish_output
        Ncurses::curs_set(1)
        Ncurses::endwin
      end
      
      def mPP_WHAT(data)
        @what = data
      end
      
      def mPP_SLIDES(data); @scounter += 1; end
      def mOP_SLIDES(data)
        @ccounter += 1
        @win::clear
        lines = @win.getmaxy
        columns = @win.getmaxx
        @win.mvaddstr(lines-2,0, "-"*columns) 
        @win.mvaddstr(lines-1,0, @what) 
        num = "#{@ccounter}/#{@scounter}"
        @win.mvaddstr(lines-1,columns-num.length, num) 
        @win.mvaddstr(0,0,'') 
      end

      def mCP_INCREMENTAL(c,i,tree,data)
        c.userdata = 
      end
      def mCP_INCREMENTAL(c,i,tree,data)
        case @win::getch
          when Ncurses::KEY_LEFT:
            @win.mvaddstr(1,1,c) 
          when Ncurses::KEY_RIGHT:
        end  
      end
      def mOP_INCLUDE(data)
      end

      def mOP_RED(data); set_color(1); end
      def mCP_RED(data); set_color(0); end
      def mOP_BLUE(data); set_color(2); end
      def mCP_BLUE(data); set_color(0); end
      def mOP_STRONG(data); @win::attron(Ncurses::A_BOLD); end
      def mCP_STRONG(data); @win::attroff(Ncurses::A_BOLD); end

      def string(data); @win::addstr data; end

      def set_color(color_pair)
        if Ncurses::respond_to?(:color_set)
          @win::color_set(color_pair, nil)
        else
          @win::attrset(Ncurses::COLOR_PAIR(color_pair))
        end
      end
      private :set_color
    end
  end
end
