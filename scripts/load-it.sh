#!/usr/bin/env bash
set -x

# deploy load-generator
#kubectl run -it load-generator --image=busybox --restart=Never --rm -- /bin/sh -c "while true; do wget -q -O /dev/null http://php-apache; done"
#kubectl run load-generator --image=busybox --restart=Never --rm -- /bin/sh -c "while true; do wget -q -O /dev/null http://php-apache; done"&

# multiply it
myCount='4'
printf '\n\n%s\n' "Print $myCount elements in the array..."
for (( i = 0; i < "$myCount"; i++ )); do
    kubectl exec -it load-generator -- /bin/sh -c "while true; do wget -q -O - http://php-apache; done"
done

