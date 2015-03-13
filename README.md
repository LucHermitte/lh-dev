# Introduction

lh-dev is a VimL for plugins oriented toward coding. It provides language independent functions that can be used by these plugins. The functions themselves can be specialized on a filetype basis.

I'll first present options that end-user of plugins based on lh-dev may tune, then the API itself for coding plugin authors.



# Commands

lh-dev defines the following commands:
  * `:AddStyle`, which is meant to be used to tune the [styling options](#formatting-of-brackets-characters)
  * `:NameConvert` that converts the identifier under to cursor to one of the following naming policy (the command supports autocompletion):
    * upper\_camel\_case, lower\_camel\_case, underscore/snake, variable,
    * getter, setter, local, global, member, static, constant, param (the exact conversion process can be tuned thanks to the [following options](#naming-conventions)).


# Options

## Styling options

Snippets for [lh-cpp](http://github.com/LucHermitte/lh-cpp) and
[mu-template](http://github.com/LucHermitte/mu-template), and refactorings from
[lh-refactor](http://github.com/LucHermitte/lh-refactor) exploit the styling
options offered by lh-dev.

### Naming conventions

Naming conventions can be defined for:
  * variables (main name)
  * global and local variables
  * member and static variables
  * (formal) parameters
  * constants
  * getters and setters

It is done, respectively, with the [options](#options):
  * `(bg):{ft_}naming_strip_re` and `(bg):{ft_}naming_strip_subst`,
  * `(bg):{ft_}naming_global_re`, `(bg):{ft_}naming_global_subst`, `(bg):{ft_}naming_local_re`, and `(bg):{ft_}naming_local_subst`,
  * `(bg):{ft_}naming_member_re`, `(bg):{ft_}naming_member_subst`, `(bg):{ft_}naming_static_re`, and `(bg):{ft_}naming_static_subst`,
  * `(bg):{ft_}naming_param_re`, and `(bg):{ft_}naming_param_subst`,
  * `(bg):{ft_}naming_constant_re`, and `(bg):{ft_}naming_constant_subst`,
  * `(bg):{ft_}naming_get_re`, `(bg):{ft_}naming_get_subst`, `(bg):{ft_}naming_set_re`, and `(bg):{ft_}naming_set_subst`

Once in the _main name_ form, the `..._re` regex options match the _main name_ while the `..._subst` replacement text is applied instead.

You can find examples for these options in mu-template
[template](http://github.com/LucHermitte/mu-template/blob/master/after/template/vim/internals/vim-rc-local-cpp-style.template)
used by [BuildToolsWrapper](http://github.com/LucHermitte/BuildToolsWrapper)'s
`:BTW new_project` command.

### Formatting of brackets characters

The aim of `:AddStyle` (and of `lh#dev#style#get()` and `lh#dev#style#apply()`) is to define how things should get written in source code.

For instance, some projects will want to have open curly-brackets on new lines (see Allman indenting style), other will prefer to have the open bracket on the same line as the function/control-statement/... (see K&R indenting style, Java coding style, ...)

lh-dev doesn't do any replacement by itself. It is expected to used by
snippet plugins. So far, only [mu-template](http://github.com/LucHermitte/mu-template) and [lh-cpp](http://github.com/LucHermitte/lh-cpp) exploit this feature.

`:AddStyle` is meant to be used by end users -- while `lh#dev#style#get()` and `lh#dev#style#apply()` are meant to be used by plugin developers that want to exploit end-user coding style.


`:AddStyle {key} [-buffer] [-ft[={ft}]] {Replacement}`
  * `{key}` is a regex that will get replaced automatically (by plugins supporting this API)
  * `{replacement}` is what will be inserted in place of `{key}`
  * "`-buffer`" defines this association only for the current buffer. This option is meant to be used with plugins like [local\_vimrc](https://github.com/LucHermitte/local_vimrc).
  * "`-ft[={ft}]`" defines this association only for the specified filetype. When `{ft}` is not specified, it applies only to the current filetype. This option is meant to be used in .vimrc, in the global zone of |filetype-plugin|s or possibily in [local\_vimrcs](https://github.com/LucHermitte/local_vimrc) (when combined with "`-buffer`").

Examples:

```vim
" # Space before open bracket in C & al {{{2
" A little space before all C constructs in C and child languages
" NB: the spaces isn't put before all open brackets
AddStyle if(     -ft=c   if\ (
AddStyle while(  -ft=c   while\ (
AddStyle for(    -ft=c   for\ (
AddStyle switch( -ft=c   switch\ (
AddStyle catch(  -ft=cpp catch\ (

" # Ignore style in comments after curly brackets {{{2
AddStyle {\ *// -ft=c \ &
AddStyle }\ *// -ft=c &

" # Multiple C++ namespaces on same line {{{2
AddStyle {\ *namespace -ft=cpp \ &
AddStyle }\ *} -ft=cpp &

" # Doxygen {{{2
" Doxygen Groups
AddStyle @{  -ft=c @{
AddStyle @}  -ft=c @}

" Doxygen Formulas
AddStyle \\f{ -ft=c \\\\f{
AddStyle \\f} -ft=c \\\\f}

" # Default style in C & al: Stroustrup {{{2
AddStyle {  -ft=c \ {\n
AddStyle }; -ft=c \n};\n
AddStyle }  -ft=c \n}\n

" # Java style {{{2
" Force Java style in Java
AddStyle { -ft=java \ {\n
AddStyle } -ft=java \n}
```

When you wish to adopt Allman coding style, in `${project_root}/_vimrc_local.vim`
```vim
   AddStyle { -b \n{\n
   AddStyle } -b \n}
```


Local configuration (with "`-buffer`") have the priority over filetype
specialized configuration (with "`-ft`").


## Inherited filetypes

All the options available though lh-dev and its API (`lh#dev#get#option()`) can be specialized for each filetype. Doing so for every filetype will quickly become cumbersome when these filetypes have a lot in common like C and C++. To simplify options tuning, lh-dev supports filetype inheritance.

By default, C++ option settings inherits C option settings. In future versions, Java option settings may also inherit C or C++ option settings.

If you want to define new inheritance relations between filetypes, send me an email for me to add to it to the default configuration, or do so in your `.vimrc` with

```vim
:let `g:{ft}_inherits = 'ft1,ft2,...'`
```

# API

This part is just a draft for the moment.

## Themes

  * style
  * naming
  * class
  * type
  * function
  * instruction
  * tags

## Filetype polymorphism

Most features provided by lh-dev can be specialized according to the filetype, usually of the current file.

### Options

Options can be obtained with `lh#dev#option#get(name, filetype, default [, scopes])`

This returns which ever exists first among: `b:{filetype}_{name}`, or `g:{filetype}_{name}`, or `b:{name}`, or `g:{name}`. `{default}` is returned if none exists.

#### Notes
  * Filetype inheritance is supported.
  * The order of the scopes for the variables checked can be specified through the optional argument {scope}

#### How to set these variables ?
  * `g:{name}` is a global default option for all filetypes best set from a `.vimrc` or a plugin
  * `g:{filetype}_{name}` is a global default option for a specific filetype (and its sub-filetypes) best set from a `.vimrc` or a plugin
  * `b:{name}` is a local option for all filetypes, best set for a [vimrc\_local](https://github.com/LucHermitte/local_vimrc), or possibly a ftplugin.
  * `b:{filetype}_{name}` is a local option for a specific filetype (and its sub-filetypes), best set for a [vimrc\_local](https://github.com/LucHermitte/local_vimrc), or possibly a ftplugin.


### Functions

Entry point: `lh#dev#{theme}#function()`

Default function: `lh#dev#{theme}#_function()`

Specialized function: `lh#dev#{filetype}#{theme}#_function()`

`lh#dev#option#call(name, filetype [, parameters])`

### Filetype inheritance
`lh#dev#option#inherited_filetypes(filetypes)`

## Contributing
### Language Analysis

# Installation
  * Requirements: Vim 7.+, [lh-vim-lib](http://github.com/LucHermitte/lh-vim-lib), [lh-tags](http://github.com/LucHermitte/lh-tags)
  * Install with [vim-addon-manager](https://github.com/MarcWeber/vim-addon-manager) any plugin that requires lh-dev should be enough.
  * With [vim-addon-manager](https://github.com/MarcWeber/vim-addon-manager), install lh-dev (this is the preferred method because of the [dependencies](http://github.com/LucHermitte/lh-vim-lib/blob/master/addon-info.txt)).
```vim
ActivateAddons lh-dev
```
  * Vundle/NeoBundle:
```vim
Bundle 'LucHermitte/lh-vim-lib'
Bundle 'LucHermitte/lh-tags'
Bundle 'LucHermitte/lh-dev'
```
  * Clone from the git repositories
```
git clone git@github.com:LucHermitte/lh-vim-lib.git
git clone git@github.com:LucHermitte/lh-tags.git
git clone git@github.com:LucHermitte/lh-dev.git
```
