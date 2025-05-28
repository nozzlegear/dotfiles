function age_string --description 'Encrypts a text string using age'
    set prompt_text "Text to encrypt"
    set carat "❯"
    set prompt "set_color green; echo $prompt_text; set_color normal; echo '$carat '"
    echo (read -p "$prompt" -s) | age --encrypt --armor --passphrase
end
