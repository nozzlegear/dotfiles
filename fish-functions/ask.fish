function ask
    set -l model

    if test (count $argv) -gt 1
        # Remove "code" from the argv array
        set model "$argv[1]"
        set -e argv[1]
    else
        set model "llama3"
    end

    if test (count $argv) -eq 0
        ollama run --nowordwrap "$model"
    else
        ollama run --nowordwrap "$model" "$argv"
    end
end