Author: Charles Josiah<br>
Author: Jhonata Lamim - Eximio TI

# Exemplo da aplicação do Keepalived no ambiente do Oracle Cloud

Objetivo: 
 - manter um sistema redundante com o "ip flutuante"/VRRP dentro de 2 servidores Oracle no ambiente de Oracle Cloud. 
 Para caso tiver a falha do servidor principal o IP seja migrado para o servidor auxiliar.

Documentação base: 
 - https://docs.oracle.com/en/operating-systems/oracle-linux/7/admin/section_uxg_lzh_nr.html
 - https://fajlinux.com.br/high-availability/configurando-keepalived-no-redhat-6-7/<br>
e muitas outras links e sites.

Mas nem tudo são "flores": 
 - O problema encontramos algumas limitações e/ou bloqueios devido ao provedor ser no OracleCloud (não testamos na AWS/Azuere e outros).
Sabemos que, o keepalived utiliza pacotes do tipo multicast e advertisements para determinar se o host esta UP ou Down. 
Primeiro problema os pacotes multicast e advertisements são bloqueados dentro da rede do OracleCloud.
E segundo problema não consigo 
