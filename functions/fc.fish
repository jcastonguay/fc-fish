function fc --description 'Edit the command history list in EDITOR'
    #TODO: prevent fc from being a part of the history
    #TODO: add command substitution with -s optional foo=bar

    set -l options l/list r/reverse n/nonumbers s/noedit e/editor=
    argparse -n fc --max-args=2 -i $options -- $argv
    or return

    if set -q _flag_nonumbers
        if not set -q _flag_list
            echo fc: option requires -l
            return 1
        end
    end

    # swap
    if set -q _flag_reverse
        set -l temp $start_index
        set start_index $end_index
        set end_index $temp
    end

    if set -q _flag_list
        set -l start_index 1
        set -l end_index 16

        if test $(count $argv) -eq 1
            set end_index (math $argv[1])
        else if test $(count $argv) -eq 2
            set start_index (math $argv[1])
            set end_index (math $argv[2])
        end

        if set -q _flag_nonumbers
            for i in (seq $start_index $end_index)
                echo "$history[$i]"
            end
        else
            for i in (seq $start_index $end_index)
                echo "$i  $history[$i]"
            end
        end
        return 0
    end

    if set -q _flag_editor
        set -fx VISUAL $_flag_editor
    end

    if test $(count $argv) -eq 0
        commandline -t $history[1]
        if not set -q _flag_noedit
            edit_command_buffer
        end
        return 0
    end

    if test $(count $argv) -eq 1
        commandline -t $history[(math $argv[1])]
        if not set -q _flag_noedit
            edit_command_buffer
        end
        return 0
    end

    if test $argv[1] -eq 0
        set argv[1] 1
    end

    if test $argv[2] -eq 0
        set argv[2] 1
    end

    commandline -r -- $history[(math $argv[1])..(math $argv[2])]
    if not set -q _flag_noedit
        edit_command_buffer
    end
end
