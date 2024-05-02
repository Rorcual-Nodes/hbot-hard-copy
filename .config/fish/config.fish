
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /root/miniconda3/bin/conda
    eval /root/miniconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/root/miniconda3/etc/fish/conf.d/conda.fish"
        . "/root/miniconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/root/miniconda3/bin" $PATH
    end
end
# <<< conda initialize <<<

