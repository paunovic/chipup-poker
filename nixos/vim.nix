{config,pkgs,...}:

let
  myVim = pkgs.vim_configurable.customize {
    name = "vim";
    vimrcConfig = {
      customRC = ''
        syntax on
        set nu
        set foldmethod=indent
        set foldcolumn=5
        set listchars=tab:->
        set list
        set backspace=indent,eol,start
        nmap <F3> :!ninja <enter>
        map <F7> :tabp<enter>
        map <F8> :tabn<enter>
        set expandtab
        set softtabstop=2
        set shiftwidth=2
      '';
      vam.pluginDictionaries = [ { names = [ "vim-nix" "youcompleteme" ]; } ];
    };
  };
in
{
  environment.systemPackages = [ myVim ];
  environment.shellAliases.vi = "vim";
}
