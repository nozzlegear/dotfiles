function clamp --argument-names min --argument-names preferred --argument-names max
    if test $preferred -lt $min
        echo $min
    else if test $preferred -gt $max
        echo $max
    else
        echo $preferred
    end
end
