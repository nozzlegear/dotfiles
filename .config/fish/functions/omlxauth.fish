function omlxauth --description 'Writes the oMLX API key to stdout'
    # Only echo if this is command substitution (e.g. `set foo (omlxauth)` or `curl -H "Authorization: $(omlxauth)"`)
    if status is-command-substitution
        set -l sops_config_file "$HOME/.config/lnk/.sops.yaml"
        set -l omp_models_file "$HOME/.omp/agent/models.yml"

        sops \
            --config "$sops_config_file" \
            decrypt \
            --extract '["providers"]["high-charity"]["apiKey_encrypted"]' \
            "$omp_models_file"
    else
        set_color yellow
        echo 'Refusing to write key unless command substitution is used, e.g. `set foo (omlxauth)` or `curl -H "Authorization: $(omlxauth)"`'
    end
end
