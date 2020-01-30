Author: Charles Josiah<br>
Author: Jhonata Lamim - Eximio TI

# Exemplo da aplicação do Keepalived no ambiente do Oracle Cloud

Objetivo: 
 - manter um sistema redundante com o "ip flutuante"/VRRP dentro de 2 servidores Oracle no ambiente de Oracle Cloud. 
 Para caso tiver a falha do servidor principal o IP seja migrado para o servidor auxiliar.

Documentação base: 
 - https://docs.oracle.com/en/operating-systems/oracle-linux/7/admin/section_uxg_lzh_nr.html
 - https://fajlinux.com.br/high-availability/configurando-keepalived-no-redhat-6-7/<br>
 - https://medium.com/oracledevs/automatic-virtual-ip-failover-on-oracle-cloud-infrastructure-ce28dc293b04
 - https://blogs.oracle.com/cloud-infrastructure/automatic-virtual-ip-failover-on-oracle-cloud-infrastructure-looks-hard%2c-but-it-isnt
e muitas outras links e sites.

Mas nem tudo são "flores": 
 - O problema encontramos algumas limitações e/ou bloqueios devido ao provedor ser no OracleCloud (não testamos na AWS/Azure/Google e outros). Sabemos que, o keepalived utiliza pacotes do tipo multicast e advertisements para determinar se o host esta UP ou Down. Esses pacotes são bloqueados dentro da rede do Oracle Cloud.
 - E outra segunda limitação, é preciso "desassociar" o IP da interface do servidor master e associar no servidor slave; e vice versa. A cada movimentação do IP dentro da estrutura. Bem diferente que o nosso habitual linux...

Porem, depois de muito teste, ajustes, suor, tudo foi ageitado e funciona perfeitamente. Vou deixar no git os arquivos como exemplo. E eventual duvida, favor entrar em contato.

Diagrama basico/topologia da estrutura: 


<p align="center">
<br>
<img  height="542" width="542" src="https://raw.githubusercontent.com/charles-josiah/confz/master/OracleCloud/Keepalived/topologia-oracle-cloud-keepalived.png">
</p>
