#!/bin/bash
# esse contem a "magica" para dessasoriar e associar novamente o ip no outro host
# antes que perguntem, não esta elegante, pode ser melhorado em muito :D 
# funciona muito legal :D
# deve ser copiado em ambos os servidores, e deixado no diretorio root. Caso queira deixar em outro local, é so ajustar os scripts e configurações /etc/

TYPE=$1
NAME=$2
STATE=$3

log=/var/log/keepalived.log
VNIC_APP02=<ID DOIDO DA PLACA DE REDE>
VNIC_APP01=<ID DOIDO DA PLACA DE REDE> 


master(){
 
  echo "`date ` - `hostname` - MASTER - $1 $2 $3" >> $log

  if [ "`hostname`" =  "srvapp02" ]; then 
      echo "VNIC ID: $VNIC_APP02 " >> $log
      /root/bin/oci network vnic assign-private-ip --unassign-if-already-assigned --vnic-id $VNIC_APP02  --ip-address 10.0.0.100 >> $log  2>&1 
  fi

  if [ "`hostname`" = "srvapp01" ]; then
      echo "VNIC ID: $VNIC_APP01 " >> $log
      /root/bin/oci network vnic assign-private-ip --unassign-if-already-assigned --vnic-id $VNIC_APP01  --ip-address 10.0.0.100 >> $log  2>&1 

  fi 
  

}



case $STATE in
        "MASTER") master 
                  ;;
        "BACKUP") echo "`date` - BACKUP - $1 $2 $3" >> $log 
                  ;;
        "FAULT")  echo "`date` - FAULT $1 $2 $3" >> $log
                  exit 0
                  ;;
        *)        echo "`date ` - OPCAO NAO CADASTRADA  $1 $2 $3" >> $log
                  exit 1
                  ;;
esac
