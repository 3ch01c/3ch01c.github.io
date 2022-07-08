# Get a list of tunneled routes
ROUTES=(`netstat -rn | grep -E 'utun\d' | awk '{OFS=","; print $1,$2,$4 }'`)
for ROUTE in ${ROUTES[@]}; do
  #echo "sudo route delete -inet6 -ifscope ${INTERFACE} default fe80::%${INTERFACE}"
  echo $ROUTE
  IFSCOPE=`echo $ROUTE | awk -F, '{ print $3 }'`
  NET=`echo $ROUTE | awk -F, '{ print $1 }'`
  if [[ $NET == "default" ]]; then
    NET=`echo $ROUTE | awk -F, '{ print $2 }'`
    COMMAND="sudo route delete -inet6 -ifscope $IFSCOPE default $NET"
  else
    COMMAND="sudo route delete -inet6 -ifscope $IFSCOPE -net $NET"
  fi
  echo $COMMAND
  eval $COMMAND
done
