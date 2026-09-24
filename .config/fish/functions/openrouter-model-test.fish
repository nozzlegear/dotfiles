function openrouter-model-test --description 'Tests whether a model can be used on Openrouter when taking workspace guardrails into account' --argument-names model
    # Get the openrouter key
    set key (openrouter)
    set content (printf '{"model":"%s","messages":[{"role":"user","content":"ping"}],"max_tokens":1}' $model)

    # Easiest way to test this is to just make a call to the API using the API key
    curl https://openrouter.ai/api/v1/chat/completions \
        -H "Authorization: Bearer $key" \
        --json $content
end
