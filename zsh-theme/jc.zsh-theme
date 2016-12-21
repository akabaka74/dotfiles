#source ~/.zsh/zsh-vcs-prompt/zshrc.sh
ZSH_VCS_PROMPT_ENABLE_CACHING='true'
RPROMPT='$(svn_prompt_info)'

USER_COLOR="red"
HOSTNAME_COLOR="green"
if [[ "$HOSTNAME" = vps* ]]; then
  TOP_FUNC="$(date)"
  HOSTNAME_COLOR="red"
elif [ "$USER"	= jc ]; then
  TOP_FUNC=`battery_charge()`
  USER_COLOR="green"
fi

local user="%{$fg[$USER_COLOR]%}%n@%m%{$reset_color%}%(?.=>.$fg[$HOSTNAME_COLOR][%?]=>$reset_color)"

precmd() {
  RIGHT=""
  LEFT="$FG[135]${(r:$COLUMNS::_:)}$reset_color
$FG[099]$TOP_FUNC:$FG[165]$(pwd)$reset_color"
  RIGHTWIDTH=$(($COLUMNS-${#LEFT}))
  print $LEFT${(l:$RIGHTWIDTH:)RIGHT}
}

PROMPT='${user}'


function battery_charge() {
    if [ -e /bin/battery.py ]
    then
        echo `python /bin/battery.py`
    else
        echo ''
    fi
} 
	
function svn_prompt_info {
    # Set up defaults
    local svn_branch=""
    local svn_repository=""
    local svn_version=""
    local svn_change=""

    # only if we are in a directory that contains a .svn entry
    if  svn info &>/dev/null ; then
        # query svn info and parse the results
        svn_branch=`svn info | grep '^URL:' | egrep -o '((tags|branches)/[^/]+|trunk).*' | sed -E -e 's/^(branches|tags)\///g'`
        svn_repository=`svn info | grep '^Repository Root:' | egrep -o '(http|https|file|svn|svn+ssh)/[^/]+' | egrep -o '[^/]+$'`
        svn_version=`svnversion -n`
        
        # this is the slowest test of the bunch
        change_count=`svn status | grep "?\|\!\|M\|A" | wc -l`
        if [ "$change_count" != "       0" ]; then
            svn_change=" [dirty]"
        else
            svn_change=""
        fi
        
        # show the results
        echo "%{$fg[blue]%}$svn_repository/$svn_branch @ $svn_version%{$reset_color%}%{$fg[yellow]%}$svn_change%{$reset_color%}"
        
    fi
}
