"=============================================================================
" $Id$
" File:		tests/lh/dev-naming.vim                           {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	0.0.1
" Created:	05th Oct 2009
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	«description»
" 
"------------------------------------------------------------------------
" Installation:	«install details»
" History:	«history»
" TODO:		«missing features»
" }}}1
"=============================================================================

UTSuite [lh-dev] Testing lh#dev#naming naming functions

runtime autoload/lh/dev/option.vim
runtime autoload/lh/dev/naming.vim

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
function! s:Test_2_name()
  Assert 'name' == lh#dev#naming#variable('name', '')
  Assert 'name' == lh#dev#naming#variable('_name')
  Assert 'name' == lh#dev#naming#variable('name_')
  Assert 'name' == lh#dev#naming#variable('getName')
  Assert 'name' == lh#dev#naming#variable('setName')
  Assert 'name' == lh#dev#naming#variable('g_name')
  Assert 'name' == lh#dev#naming#variable('m_name')
endfunction

function! s:Test_2_getter()
  Assert 'getName' == lh#dev#naming#getter('name', '')
  let b:FT_naming_get_subst = 'get_&'
  Assert 'get_name' == lh#dev#naming#getter('name', 'FT')
endfunction

function! s:Test_2_setter()
  Assert 'setName' == lh#dev#naming#setter('name', '')
  let b:FT_naming_set_subst = 'set_&'
  Assert 'set_name' == lh#dev#naming#setter('name', 'FT')
endfunction

function! s:Test_2_local()
  Assert 'name' == lh#dev#naming#local('name', '')
  let b:FT_naming_local_subst = 'l_&'
  Assert 'l_name' == lh#dev#naming#local('name', 'FT')
endfunction

function! s:Test_2_global()
  Assert 'g_name' == lh#dev#naming#global('name', '')
  let b:FT_naming_global_subst = '&'
  Assert 'name' == lh#dev#naming#global('name', 'FT')
  Assert 'g:name' == lh#dev#naming#global('name', 'vim')
endfunction

function! s:Test_2_param()
  Assert 'name' == lh#dev#naming#param('name', '')
  let b:FT_naming_param_subst = '&_'
  Assert 'name_' == lh#dev#naming#param('name', 'FT')
  Assert 'a:name' == lh#dev#naming#param('name', 'vim')
endfunction

function! s:Test_2_static()
  Assert 's_name' == lh#dev#naming#static('name', '')
  let b:FT_naming_static_subst = '::&'
  Assert '::name' == lh#dev#naming#static('name', 'FT')
  Assert 's:name' == lh#dev#naming#static('name', 'vim')
endfunction

function! s:Test_2_constant()
  Assert 'NAME' == lh#dev#naming#constant('name', '')
  let b:FT_naming_constant_subst = 'k_&'
  Assert 'k_name' == lh#dev#naming#constant('name', 'FT')
endfunction

function! s:Test_2_member()
  Assert 'm_name' == lh#dev#naming#member('name', '')
  let b:FT_naming_member_subst = 'm\u&'
  Assert 'mName' == lh#dev#naming#member('name', 'FT')
  let b:FT_naming_member_subst = 'this->&'
  Assert 'this->name' == lh#dev#naming#member('name', 'FT')
endfunction


"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
