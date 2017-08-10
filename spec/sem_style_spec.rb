# encoding: UTF-8
require 'spec_helper'
require 'pp'

RSpec.describe "Semantic styles", :style do
  let (:filename) { "test.cpp" }

  # ====[ Executed once before all test {{{2
  before :all do
    if !defined? vim.runtime
        vim.define_singleton_method(:runtime) do |path|
            self.command("runtime #{path}")
        end
    end
    vim.runtime('spec/support/input-mock.vim')
    expect(vim.command('verbose function lh#ui#input')).to match(/input-mock.vim/)
    # expect(vim.echo('lh#mut#dirs#get_templates_for("cpp/abstract-class")')).to match(/abstract-class.template/)
    vim.command('SetMarker <+ +>')
    expect(vim.echo('&rtp')).to match(/lh-dev/)
  end

  # ====[ Always executed before each test {{{2
  before :each do
    expect(vim.echo('&enc')).to eq 'utf-8'
    vim.command('filetype plugin on')
    vim.command("file #{filename}")
    vim.set('ft=cpp')
    vim.command('set fenc=utf-8')
    vim.set('expandtab')
    vim.set('sw=2')
    vim.command('silent! unlet g:cpp_explicit_default')
    vim.command('silent! unlet g:cpp_std_flavour')
    # expect(vim.echo('&rtp')).to eq ""
    expect(vim.command('runtime! spec/support/c-snippets.vim')).to eq "" # if snippet
    expect(vim.command('verbose iab if')).to match(/LH_cpp_snippets_def_abbr/)
    # expect(vim.echo('exists("*lh#cpp#snippets#def_abbr")')).to eq "1"
    clear_buffer
    set_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */
    EOF
    vim.command(%Q{call append(1, ['', ''])})
    expect(vim.echo('line("$")')).to eq '3'
    expect(vim.echo('setpos(".", [1,3,1,0])')).to eq '0'
    expect(vim.echo('line(".")')).to eq '3'
  end

  # ====[ K&R {{{2
  specify "K&R", :k_r do
    expect(vim.echo('lh#dev#style#use({"indent_brace_style": "K&R"}, {"buffer": 1})')).to eq "1"
    vim.feedkeys('aif foo\<esc>')
    vim.feedkeys('i\<esc>') # pause
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */

    if (foo) {
      <++>
    }<++>
    EOF
  end

  # ====[ 1TBS {{{2
  specify "1TBS", :otbs do
    expect(vim.echo('lh#dev#style#use({"indent_brace_style": "1TBS"}, {"buffer": 1})')).to eq "1"
    vim.feedkeys('aif foo\<esc>')
    vim.feedkeys('i\<esc>') # pause
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */

    if (foo) {
      <++>
    }<++>
    EOF
  end

  # ====[ Stroustrup {{{2
  specify "Stroustrup", :stroustrup do
    expect(vim.echo('lh#dev#style#use({"indent_brace_style": "Stroustrup"}, {"buffer": 1})')).to eq "1"
    vim.feedkeys('aif foo\<esc>')
    vim.feedkeys('i\<esc>') # pause
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */

    if (foo) {
      <++>
    }
    <++>
    EOF
  end

  # ====[ Horstmann {{{2
  specify "Horstmann", :horstmann do
    expect(vim.echo('lh#dev#style#use({"indent_brace_style": "Horstmann"}, {"buffer": 1})')).to eq "1"
    vim.feedkeys('aif foo\<esc>')
    vim.feedkeys('i\<esc>') # pause
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */

    if (foo)
    { <++>
    }
    <++>
    EOF
  end

  # ====[ Pico {{{2
  specify "Pico", :pico do
    expect(vim.echo('lh#dev#style#use({"indent_brace_style": "Pico"}, {"buffer": 1})')).to eq "1"
    vim.feedkeys('aif foo\<esc>')
    vim.feedkeys('i\<esc>') # pause
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */

    if (foo)
    { <++> }
    <++>
    EOF
  end

  # ====[ Lisp {{{2
  specify "Lisp", :lisp do
    expect(vim.echo('lh#dev#style#use({"indent_brace_style": "Lisp"}, {"buffer": 1})')).to eq "1"
    vim.feedkeys('aif foo\<esc>')
    vim.feedkeys('i\<esc>') # pause
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */

    if (foo) {
      <++>}
      <++>
    EOF
    # Note: The extra indent at the end is because Vim adds an extra
    # indentation with this way of organising brackets.
  end

  # ====[ Java {{{2
  specify "Java", :java do
    expect(vim.echo('lh#dev#style#use({"indent_brace_style": "Java"}, {"buffer": 1})')).to eq "1"
    vim.feedkeys('aif foo\<esc>')
    vim.feedkeys('i\<esc>') # pause
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */

    if (foo) {
      <++>
    }<++>
    EOF
  end

  # ====[ Allman {{{2
  specify "Allman", :allman do
    expect(vim.echo('lh#dev#style#use({"indent_brace_style": "Allman"}, {"buffer": 1})')).to eq "1"
    vim.feedkeys('aif foo\<esc>')
    vim.feedkeys('i\<esc>') # pause
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */

    if (foo)
    {
      <++>
    }
    <++>
    EOF
  end

end

# vim:set sw=2:
