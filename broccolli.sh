#!/bin/bash
# 2012-04-23, Created by Hagen Fuchs <code@hfuchs.net>

debug=0

# No-ops
# ------------------------
noops="to as into I i should Should"

# Ops
# ------------------------
# visit() takes an URL, wgets it, saves it's content and sets a flag if
# succesful.
visit() {
    [ $debug -ne 0 ] && echo "[DEBUG] visit() called."
    visit_success=1
    content_to_see="$(wget -q -O - $visit_url)"
    [ $? == 0 ] && visit_success=0 && return 0
    return 1
}

# see() looks for the specified string in $content_to_see and sets its
# flag appropriately.
see() {
    [ $debug -ne 0 ] && echo "[DEBUG] see() called."
    see_success=1
    see_phrase="$1"
    echo "$content_to_see" | grep -q "$see_phrase"
    [ $? == 0 ] && see_success=0 && return 0
    return 1
}

# When() rearranges its arguments (visit > see, not see > visit), drops
# noops and evaluates the resulting chain.
When() {
    # TODO Natural Language Parser (implement either this afternoon or,
    # worst-case, over the weekend).
    for i in "$@"; do
        echo $noops | grep -q "$i" && continue
        # TODO just search for valid ops
    done
    for i in $(seq 1 $#); do
        # Wow, that's non-intuitive.
        # http://stackoverflow.com/questions/1497811/how-to-get-the-nth-positional-argument-in-bash
        word="${!i}"
        echo $noops | grep -q "$word" && continue
        # TODO Proper mapping here (command pattern, right?).
        # TODO Multiple occurences not allowed.
        [ "$word" == "visit" ] && visit_url="${@:$i+1:1}"
        [ "$word" == "see" ]   && see_phrase="${@:$i+1:1}"
        [ "$word" == "login" ] && login_creds="${@:$i+2:1}@${@:$i+1:1}"
        [ "$word" == "look" ]  && look_file="${@:$i+1:1}"
        [ "$word" == "NOT" ]   && not_op="${@:$i+1:1}"
    done

    # TODO Again: propper mapping to operational order
    visit $visit_url  &&  see $see_phrase

    # Default values (:-1) set because scripts might not have run.
    if [ ${visit_success:-1} -ne 0 ]; then
        echo "Could not visit: $visit_url."
        return 1
    fi
    if [ ${see_success:-1} -ne 0 ]; then
        echo "Could not find '$see_phrase' upon visiting $visit_url."
        return 2
    fi

    [ $debug -ne 0 ] && echo "[DEBUG] Success for test of '$visit_url'."
}
