function cat-podman-secret --argument secretName
    set secret_data (podman secret inspect "$secretName" | jq '.[0]')
    set secret_id (echo $secret_data | jq --raw-output -e '.ID')
    set secret_path (echo $secret_data | jq --raw-output -e '.Spec.Driver.Options.path + "/secretsdata.json"')
    set secret_value (jq --raw-output -e ".[\"$secret_id\"]" < "$secret_path")
    or return 1
    echo -n "$secretName: "
    set_color yellow
    echo $secret_value | base64 --decode
    set_color normal
    echo "Path: $secret_path"
end
