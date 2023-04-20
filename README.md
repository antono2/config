# Config Files
This directory contains a bunch of config files for different programs.
At the original location, where a program expects a config file, instead is a symlink like
`ln -s <Config/File> <Original/Location/File>`


## List of Symlinks
In order to allow for maximum customization, there is no script to run, but just a list of original file locations. 
| File | Original Location |
|--|--|
| .bash_aliases | ~/.bash_aliases |
| .bashrc | ~/.bashrc |
| alacritty.yml | ~/.config/alacritty.yml |
| alacritty_themes/* | ~/Configs/alacritty_themes/* - set by alacritty.yml |
| .tmux.conf | ~/Configs/.tmux.conf - set by alacritty.yml |
| kakrc | ~/workspace/kakoune/share/kak/kakrc |
| ./kak-lsp/config.toml | ~/Configs/kak-lsp/config.toml - set by kakrc |

## Installation per Symlinks

`git clone https://github.com/antono2/config ~/Configs`

For each `file`
 1. Make sure to keep any config parameters you customized in the original.
 2. Delete the original
 3. `ln -s ~/Configs/File ~/Original/Location/File`
