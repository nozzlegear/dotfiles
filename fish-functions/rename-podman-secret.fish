function rename-podman-secret --argument oldName newName
    set secret_data (podman secret inspect "$oldName" | jq '.[0]')
    set secret_id (echo $secret_data | jq --raw-output -e '.ID')
    set secret_path (echo $secret_data | jq --raw-output -e '.Spec.Driver.Options.path + "/secretsdata.json"')
    # The secret is stored as base64 when we read it, but podman will do the encoding itself.
    set secret_value (jq --raw-output -e ".[\"$secret_id\"]" < "$secret_path" | base64 --decode)
    or return 1
    # Must use -n to prevent echo from adding a newline and "corrupting" the secret, changing its value.
    echo -n $secret_value | podman secret create "$newName" -
    or return 1
end
