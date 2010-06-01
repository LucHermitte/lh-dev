"=============================================================================
" $Id$
" File:         tests/lh/dev-params.vim                           {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      0.0.1
" Created:      31st May 2010
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Unit Tests for lh#dev#c#function# functions
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/tests/lh
"       Requires Vim7+
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

UTSuite [lh-dev] Testing lh#dev#function parameters analysing functions
runtime autoload/lh/dev/option.vim
runtime autoload/lh/dev/function.vim
runtime autoload/lh/dev/c/function.vim

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
function! s:Test_Param_data()
  let pa = lh#dev#c#function#_analyse_parameter('int foo')
  Assert pa.name == 'foo'
  Assert pa.type == 'int'

  let pa = lh#dev#c#function#_analyse_parameter('int foo = 42')
  Assert pa.name == 'foo'
  Assert pa.type == 'int'
  Assert pa.default == '42'

  let pa = lh#dev#c#function#_analyse_parameter('int foo = f()')
  Assert pa.name == 'foo'
  Assert pa.type == 'int'
  Assert pa.default == 'f()'

  let pa = lh#dev#c#function#_analyse_parameter('int * foo')
  Assert pa.name == 'foo'
  Assert pa.type == 'int *'


  let pa = lh#dev#c#function#_analyse_parameter('int ** foo')
  Assert pa.name == 'foo'
  Assert pa.type == 'int **'


  let pa = lh#dev#c#function#_analyse_parameter('int *& foo')
  Assert pa.name == 'foo'
  Assert pa.type == 'int *&'


  let pa = lh#dev#c#function#_analyse_parameter('int * foo = 0')
  Assert pa.name == 'foo'
  Assert pa.type == 'int *'
  Assert pa.default == '0'

  let pa = lh#dev#c#function#_analyse_parameter('long int foo')
  Assert pa.name == 'foo'
  Assert pa.type == 'long int'

  let pa = lh#dev#c#function#_analyse_parameter('unsigned long long int foo')
  Assert pa.name == 'foo'
  Assert pa.type == 'unsigned long long int'

  let pa = lh#dev#c#function#_analyse_parameter('unsigned long foo[42]')
  Comment string(pa)
  Assert pa.name == 'foo'
  Assert pa.type == 'unsigned long []'

  let pa = lh#dev#c#function#_analyse_parameter('unsigned long foo [42][45]')
  Comment string(pa)
  Assert pa.name == 'foo'
  Assert pa.type == 'unsigned long [42][]'

  let pa = lh#dev#c#function#_analyse_parameter('std::vector<long int> foo')
  " Comment string(pa)
  Assert pa.name == 'foo'
  Assert pa.type == 'std::vector<long int>'

  let pa = lh#dev#c#function#_analyse_parameter('std::vector<long int> const& foo')
  " Comment string(pa)
  Assert pa.name == 'foo'
  Assert pa.type == 'std::vector<long int> const&'

  let pa = lh#dev#c#function#_analyse_parameter('int (&foo)[42]')
  " Comment string(pa)
  Assert pa.name == 'foo'
  Assert pa.type == 'int (&)[42]'

  " todo: add pointer to functions, 
endfunction
"------------------------------------------------------------------------
function! s:Test_split_params()
  let p = lh#dev#c#function#_split_list_of_parameters('toto t=42, titi r, tutu z=f()')
  Assert p[0] == 'toto t=42'
  Assert p[1] == 'titi r'
  Assert p[2] == 'tutu z=f()'

  let p = lh#dev#c#function#_split_list_of_parameters('toto t=42, std::string const& s, char * p, int[] i, titi r, tutu z=f()')
  Assert p[0] == 'toto t=42'
  Assert p[1] == 'std::string const& s'
  Assert p[2] == 'char * p'
  Assert p[3] == 'int[] i'
  Assert p[4] == 'titi r'
  Assert p[5] == 'tutu z=f()'

  let p = lh#dev#c#function#_split_list_of_parameters('toto t=42, std::string const&, char * p, int[] i, std::vector<short>, titi r, tutu z=f()')
  Assert p[0] == 'toto t=42'
  Assert p[1] == 'std::string const&'
  Assert p[2] == 'char * p'
  Assert p[3] == 'int[] i'
  Assert p[4] == 'std::vector<short>'
  Assert p[5] == 'titi r'
  Assert p[6] == 'tutu z=f()'

  let p = lh#dev#c#function#_split_list_of_parameters('toto t=42, std::string const&, Tpl<T1, T2, int>, titi r, tutu z=f(g(12),5)')
  Assert p[0] == 'toto t=42'
  Assert p[1] == 'std::string const&'
  " spaces are trimmed
  Assert p[2] == 'Tpl<T1,T2,int>'
  Assert p[3] == 'titi r'
  Assert p[4] == 'tutu z=f(g(12),5)'

endfunction
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
