  vim9script

  const default_pairs = {'(': ')', '[': ']', '{': '}', '''': '''', '"': '"'}

# find tab stop for a given line
# breaking words 
export def FindWordStops(str: string): list<number>
  var stops = []
  var was_blank = true
  const l = strlen(str)
  var pos = 0
  const pairs = get(b:, 'word_indent_pairs', default_pairs)
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

def Line(lnum0: string, offset: number): number
  var lnum = lnum0
  if lnum == ''
    return offset
  endif
  if lnum == 'ref' 
     if has_key(b:, 'word_indent_ref_line')
      return b:word_indent_ref_line + offset
     endif
     lnum = '.'
  endif
  return line(lnum) + offset
enddef

export def FindStopsByRegex(reg: string, line: string): list<number>
  var stops = []
  var pos = 0
  while  pos >= 0
      const [_,start,end] = matchstrpos(line, reg, pos)
      if start == -1
         break
      else
        stops->add(start + 1)
        pos = end + 1
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
  var l: number = Line(lnum, offset)
  var stops = FindWordStops(getline(l))
  var left = stops->get(0, 1000)
  while (left > 1 && l > 0)
    l = l - 1
    const new_stops = FindWordStops(getline(l))
    const first_bad = new_stops->indexof((i, v) => v >= left)
    const lefts = first_bad == -1 ? new_stops : new_stops->slice(0, first_bad)
    stops = lefts + stops
    left = stops->get(0, left)
  endwhile
  # remove 1
  const i1 = stops->index(1)
  if i1 > -1
    stops->remove(i1)
  endif
  return stops
enddef

export def SetWordStops(lnum: string, offset: number = 0): any
  if (lnum == '.' && offset == 0)
    const ref = get(b:, 'word_indent_ref_line', 0)
    if (ref == line(lnum))
      ClearCcs()
      return []
    endif
  endif
  const stops: list<number> = FindTabStopsR(lnum, offset)
  SetCcs(stops, Line(lnum, offset))
  return stops
enddef

export def ClearCcs()
  SetCcs([])
enddef

export def SetRegexStops(lnum: string, offset: number = 0): any
  const line = getline(Line(lnum, offset))
  const stops: list<number> = FindStopsByRegex(input('stops/'), line)
  g:word_indent_auto_cc = 1
  SetCcs(stops, Line(lnum, offset))
  return stops
enddef

# 1,4,6,9 => xxxx..xxx
def StopsToZebra(stops: list<number>): list<number>
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
  return cols
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

# set colorculum
export def SetCcFromVsts()
  &colorcolumn = &varsofttabstop->StrToNrs()->TabStopsToCols()->join(',')
enddef

# varsofttabstop
export def SetVstsFromCc()
  &varsofttabstop = &colorcolumn->StrToNrs()->ColsToTabStops()->join(',')
enddef

export def StrToNrs(str: string): list<number>
  return str->split(',')->map((key, val) => str2nr(val))
enddef


export def AddCc()
  var cols = &colorcolumn->StrToNrs()
  const col = getcurpos()[2]
  const i = cols->index(col)
  if i == -1
    cols->add(col)
  else
    cols->remove(i)
  endif
  SetCcs(cols)
enddef

export def SetCc()
  const col = getcurpos()[2]
  SetCcs([col])
enddef

def SetCcs(cols: list<number>, line: number=0)
  if get(g:, 'word_indent_auto_cc', 1) != 0
    &colorcolumn = cols->copy()->sort('N')->join(',')
  endif
  if get(g:, 'word_indent_auto_vsts', 1) != 0
    &varsofttabstop = cols->ColsToTabStops()->join(',')
  endif
  b:word_indent_ref_line = line
  if get(b:, 'word_indent_match_id', 0)  > 0
     # matchdelete(b:word_indent_match_id)
  endif
  sign_unplace('word_indent')
  if line != 0
        # b:word_indent_match_id  =  matchaddpos('Todo', [line])
        sign_place(0, 'word_indent', 'word_indent_ref', '%', {lnum: line})
  endif
enddef


# get stops from &colorcolumn or &varsoftabs
export def GetStops(): list<number>
  const cols = &colorcolumn->StrToNrs()
  if len(cols) > 0
    return cols
  endif
  return &varsofttabstop->StrToNrs()->TabStopsToCols()
enddef

# use last stops unless
# the line is already matching a stop
export def Indent(): number
  # 0 indent if previous line empty
  if getline(v:lnum - 1) == ""
    return 0
  endif
  var stops = GetStops()
  if len(stops) == 0
    stops = FindTabStopsR('', v:lnum - 1)
  endif

  if len(stops) == 0
    stops = [1]
  endif

  const current_indent: number = indent(v:lnum) + 1
  const current_stop: number = stops->FindNextStops(current_indent)

  if current_stop == current_indent
    # at a stop, don't change it
    return current_stop - 1
  elseif current_stop > 0
    return current_stop - 1
  endif 
  return stops[-1] - 1
enddef

export def ToggleIndent()
  if &indentexpr == "indentexpr=WordIndent#Indent()"
    :set indentexpr=
  else
    :set indentexpr=WordIndent#Indent()
  endif
enddef


# Find first stops >= given position
export def FindNextStops(stops: list<number>, pos: number): number
  const i = stops->indexof('v:val >= ' .. pos)
  if i > -1
    return stops[i]
  endif
  return 0
enddef

export def FindPreviousStops(stops: list<number>, pos: number): number
  const i = stops->indexof('v:val >= ' .. pos)
  if i == -1
    return stops[-1]
  elseif i > 0
    return stops[i - 1 ]
  endif
  return 0
enddef

# set sw so that the next shift will align the first character to with the
# next/previous tab and execute the action
export def WithShift(dir: string, cmd: string)
  const stops = GetStops()
  if stops == []
     execute cmd
  endif

  const col = max([indent('.') + 1, 1])
  const old_shiftwidth = &shiftwidth

  const sw = dir == 'left' ? col - stops->FindPreviousStops(col)
                           : stops->FindNextStops(col + 1) - col
  if sw > 0
    &shiftwidth = sw
    execute cmd
    &shiftwidth = old_shiftwidth
  endif
enddef

  
export def SetShiftWidth(dir: string, use_pos: bool)
  # save indentexpr but prevent
  # nested call to override the first old_expression
  if get(b:, 'word_indent_to_restore', 0) == 0
    b:word_indent_old_indentexpr = &indentexpr
    b:word_indent_to_restore = 1
  endif
  var stops = GetStops()
  if stops == []
    const vcol = getcurpos()[4]
    const  tab = vcol / &shiftwidth * &shiftwidth + 1
    stops = [ tab - &sw, tab, tab + &sw ]
  endif

  const col = max([indent('.') + 1, 0])
  # if a line is empty use the virtual column position instead
  # to avoid going backward.
  const vcol: number = use_pos && getline('.') == '' ?  getcurpos()[4]
                                                    : col
  const sw = dir == 'left' ? stops->FindPreviousStops(vcol)  - col
                           : (stops->FindNextStops(vcol + 1) ?? (vcol + &sw)) - col
  b:word_indent_indent_shift = sw
  &indentexpr = "indent(v:lnum)+" .. string(sw)
  &indentexpr = "WordIndent#IndentShift()"
enddef


export def RestoreShiftWidth()
  &indentexpr = get(b:, 'word_indent_old_indentexpr', '')
  b:word_indent_to_restore = 0
enddef

export def IndentShift(): number
  return max([indent(v:lnum) + b:word_indent_indent_shift, 0])
enddef

export def ShiftLeft(type=''): string
  if type == ""
    &operatorfunc = ShiftLeft
    return "g@"
  endif
  SetWordStopsIfAuto(-1)
  normal! '[
  SetShiftWidth('left', v:false)
  normal! =']
  RestoreShiftWidth()
  UnsetWordStops()
  return ""
enddef
export def ShiftRight(type=''): string
  if type == ""
    &operatorfunc = ShiftRight
    return "g@"
  endif
  normal! '[
  SetWordStopsIfAuto(-1)
  SetShiftWidth('right', v:false)
  normal! =']
  RestoreShiftWidth()
  UnsetWordStops()
  return ""
enddef

export def SetWordStopsIfAuto(offset=0)
  if get(g:, 'word_indent_auto_stops', 1) == 1
    SetWordStopsIf(offset)
  endif
enddef

# Set word stops unless it is alreayd been set
export def SetWordStopsIf(offset=0)
	if &varsofttabstop == ''
      b:word_indent_set_ = 1
      call WordIndent#SetWordStops('.', offset)
  endif
enddef

export def UnsetWordStops()
  if get(b:, 'word_indent_set_') == 1
     ClearCcs()
     b:word_indent_set_ = 0
  endif
enddef

export def ToggleWordStops2()
  if get(b:, 'word_indent_set_') == 1
    WordIndent#UnsetWordStops()
  else
    b:word_indent_set_ = 1
    SetWordStops('.', -1)
  endif
enddef
export def ToggleWordStops()
  const stops = GetStops()
  if stops == []
    WordIndent#SetWordStops('.', -1)
  else 
    SetCcs([])
  endif
enddef


export def InstallAuto(install: bool=true)
  augroup word_indent
  au!
  b:word_indent_auto = install
  if  install
    autocmd InsertEnter  * call WordIndent#SetWordStopsIf(-1)
    autocmd InsertLeave  * call WordIndent#UnsetWordStops()
  else
  endif
  augroup END            
enddef

export def ToggleAuto()
  const new = !get(g:, 'word_indent_auto_stops', 1)
  g:word_indent_auto_stops = new
  InstallAuto(new)
  echo "word indent auto" (new ? 'on' : 'off')
enddef
defcompile

export def SetPreviousLine(offset= -1)
  var ref = get(b:, 'word_indent_ref_line', 0)
  if ref == 0
        return
  endif

  # skip current line in edit mode
  const current = line('.')
  if ref + offset == current
    ref = current
  endif
  SetWordStops('', ref + offset)
enddef


sign define word_indent_ref text=¶ texthl=Special
