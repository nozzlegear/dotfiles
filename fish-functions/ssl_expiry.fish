# A function to check the expiration date of an SSL certificate
function ssl_expiry -a "domain" -d "Gets the SSL certificate expiration date for the given website"
    echo | openssl s_client -connect "$domain:443" 2>/dev/null | openssl x509 -noout -enddate
end
