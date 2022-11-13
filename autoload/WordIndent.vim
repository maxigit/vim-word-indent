vim9script

const pairs = {'(': ')', '[': ']', '{': '}', '''': '''', '"': '"'}

# find tab stop for a given line
# breaking words 
export def FindTabStops(str: string): list<number>
  var stops = []
  var was_blank = true
  const l = strlen(str)
  var pos = 0

  while (pos < l)
    const c = str[pos]
    pos += 1
    var cclass = charclass(c)
    var pair = pairs->get(c, null)
    if  (was_blank || pair != null)
      if (cclass == 0) # blank
        continue
      endif

      was_blank = false
      stops->add(pos)
      if (pair == null || pos == l) 
        # normal meet a word or last character
      else # parenthesis, skip til matching
        var level = 1
        for pos2 in range(pos, l - 1)
          const cursor = str[pos2]
          if (cursor == c)
            level += 1
          elseif (cursor == pair)
            level -= 1
            if (level <= 0 || pair == c )
              #               ' or " no nesting
              # closed pair found skip to next character
              pos = pos2 + 1
              break
            endif
          endif
        endfor
      endif
    else
      if (cclass == 0) 
        was_blank = true
      endif
    endif
  endwhile

  return stops
enddef

# Find words from given line (and recursively
# line above if a line is indented
# Ex
#
#   A1    A2    A3
#            B1    B2
#               C1    C2
#   *     *  *  *     *
#   Returns
#   A1 A2 B1 C1 C2
#     
export def FindTabStopsR(lnum: string, offset: number): list<number>
  var l: number = line(lnum) + offset
  var stops = FindTabStops(getline(l))
  var left = stops->get(0, 1000)
  while (left > 1 && l > 0)
    l = l - 1
    const new_stops = FindTabStops(getline(l))
    const first_bad = new_stops->indexof((i, v) => v >= left)
    const lefts = new_stops->slice(0, first_bad)
    stops = lefts + stops
    left = stops->get(0, left)
  endwhile
  return stops
enddef

export def SetTabStops(lnum: string, offset: number = 0): any
  const stops: list<number> = FindTabStopsR(lnum, offset)
  var diffs: list<number> = []
  var last = 1
  for stop in stops
    if stop != last 
      diffs->add(stop - last)
    endif
    last = stop
  endfor
  &vartabstop = diffs->join(',')
  var cols = []
  var start =  0
  for stop in stops
    if (start > 0)
      cols = cols + range(start, stop - 1)
      start = 0
    else
      start = stop
    endif
  endfor
  &colorcolumn = cols->join(',')
  &colorcolumn = stops->join(',')
  return stops
enddef

export def ColsToTabStops(cols: list<number>): list<number>
  var last = 1
  var stops = []
  for col in cols
    if col != last
      stops->add(col - last)
    endif
    last = col
    endfor
  return stops
enddef

export def TabStopsToCols(stops: list<number>): list<number>
  var cols = []
  var col = 1
  for stop in stops 
    col += stop
    cols->add(col)
  endfor
  return cols
enddef


defcompile
