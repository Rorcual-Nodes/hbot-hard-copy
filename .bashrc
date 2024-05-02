

export FUN_FRONTEND_PORT=50000
export FUN_FRONTEND_COMMAND="APP=fun-frontend yarn start --host"
export FILEBROWSER_PORT=50002
export VITE_FILEBROWSER_PORT=$FILEBROWSER_PORT
export FILEBROWSER_COMMAND="APP=filebrowser filebrowser --address=0.0.0.0 -p $FILEBROWSER_PORT -r ../shared"
export FUN_CLIENT_PORT=50001
export FUN_CLIENT_COMMAND="APP=fun-client python app.py"
export HB_GATEWAY_PORT=15888
export HB_GATEWAY_COMMAND="APP=hb-gateway yarn start"
export HB_CLIENT_COMMAND="APP=hb-client python bin/hummingbot_quickstart.py; exit"


export ARCHITECTURE=x86_64
export OS=Linux
export FILE_EXTENSION=sh
export IS_RASPBERRY=FALSE
export PATH=/root/miniconda3/bin:$PATH
export MINICONDA_VERSION=Miniconda3-py38_4.10.3-Linux-x86_64.sh
export MINICONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-py38_4.10.3-Linux-x86_64.sh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/root/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/root/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/root/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/root/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export MINICONDA_ENVIRONMENT=hummingbot
source /root/miniconda3/etc/profile.d/conda.sh && conda activate hummingbot
source /root/shared/scripts/initialize.sh
# Credentials Section - Begin
export ENCRYPTED_CREDENTIALS="fRy7YqSEhkQOAVW/6DuYjZchh8gmtozShOwex73hflFPanzDAxpkUPow+jSmBKxv9gD8299MUgMT
BvFUErKm5qcYZb6FNbmMrklj92YVIojvlLNlBa07UyeQMQAHdkpH5gKCIpISMFShch36Y7DIiuFH
TTNPb55snpK5L2pstXcjjvOmxJk1dF3IG45uuqx7TDfOpZGy7+uYfJ1g5JeAezGydGR8XhGz6o0j
rfzrkjUGiBtrQUZgPTttA43HZJ8ceNjzZLC180dxtVGuqU4m5SdAP826o1sgyTBCtsppSHnUK/dy
jFQ9a+Fxht5LZnsaJ11fYWxBOA4HyOxhdBsbamrHFf4f5bxfnNaU8/nGsYI//ZJHxEXHp5VfzRc0
acUW5yXwKlz0BzILwAB77xkFcc0gxeVZHh3p6r4JqqZS5Z7MZvaiKBiNsP4KECID4k/ysSYNmzAm
03Bfhbg3vQkzYK1cEm+FZVmza3zVVwTfWNJKQ2RKI4Rr2lvXGWKOpwD1Gv3WsRrW8kxHDcCp24lv
igdW6Ked80kQfB5ufcGMMvFN4T4E/OzPJWDP8PhxsxcibHluQA7Q/xPPTpwFy4Fz0cc02I8MIRL1
y7YeUYAZeKG5RdpU9sQJbvw/0GXVOHtV4b94I05T9HrZgXP/sgLoVRpyai5kZnqCUJktTsUeEbA="
export NON_ENCRYPTED_CREDENTIALS_SHA256SUM="819d3a98111275dcb61c0c8e3af010c9083d55154d1851d0c6f3ffc28e10fdc6"
# Credentials Section - End
