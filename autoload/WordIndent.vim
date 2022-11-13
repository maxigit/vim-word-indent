vim9script

# const pairs = {'(': ')', '[': ']', '{':'}', '''' : '''', '"', '"'}
const pairs = {}

# find tab stop for a given line
# breaking words 
export def FindTabStops(str: string): list<number>
  var stops = []
  var pos = 0
  var is_blank = true

  for c in str
    pos += 1
    var cclass = charclass(c)
    if  (is_blank)
      if (cclass == 0) # blank
        continue
      endif

      var pair = pairs->get(c, null)
      if (pair == null) 
        # normal meet a word
        is_blank = false
        stops->add(pos)
      else # parenthesis, skip til matching
        return pair
      endif
    else
      if (cclass == 0) 
        is_blank = true
      endif
    endif
  endfor

  return stops
enddef
