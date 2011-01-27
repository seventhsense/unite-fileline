" A unite source for file contents.
" Version: 0.0.1
" Author : pekepeke <pekepekesamurai@gmail.com>
" License: Creative Commons Attribution 2.1 Japan License
"          <http://creativecommons.org/licenses/by/2.1/jp/deed.en>

let s:save_cpo = &cpo
set cpo&vim

let s:source = {
\   'name': 'fileline',
\   'max_candidates': 30,
\ }

function! s:source.gather_candidates(args, context) " {{{2
  let source = a:context['source']['name']
  let pos = stridx(source, '/')
  if has_key(a:context['source'], 'source__fileline')
    let path = a:context['source']['source__fileline']
  elseif len(a:args) <= 0
    return []
  else
    let path = a:args[0]
  endif
  return s:file_filter(path, a:context)
endfunction

function! s:file_filter(path, context) " {{{2
  let path = expand(a:path)
  if !filereadable(path)
    return []
  endif
  let lines = readfile(path)
  return map(filter(lines, 'v:val != "" && strpart(v:val, 0, 1) != "#" && v:val !~ "^\\s*$"'), '{
        \   "word": substitute(v:val, "^\\s*\\|\\s*$", "", "g"),
        \   "source": a:context["source"]["name"],
        \   "kind": "word",
        \ }')
endfunction

function! s:additional_sources() " {{{2
  if exists('g:unite_fileline_register_files')
    return map(g:unite_fileline_register_files, 's:define(v:val)')
  endif
  return []
endfunction

function! s:define(path) " {{{2
    let source = copy(s:source)
    let source.name = 'fileline/' . fnamemodify(v:val, ':t:r')
    let source.source__fileline = a:path
    return source
endfunction

function! unite#sources#fileline#define() " {{{2
  return [s:source] + s:additional_sources()
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo

