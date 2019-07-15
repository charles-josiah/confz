# Exemplos de utilização do FirewallD

- Serviços customizados, disponivel ./services
  * totvs.xml - porta e serviço para TOTVS FLUIG
  * check_mk.xml - porta e serviço para CHECK_MK
  
### Mini-howto:

- Para ativação e utilização dos arquivos xml:
  - copiar os arquivo totvs.xml para /etc/firewalld/services
  - gerar link simbolico  ln -s totvs.xml /usr/lib/firewalld/services


- Adicionar o servico ao firewalld de forma permanente
  * firewall-cmd --zone=public --add-service=vnc-server  --permanent

- Adicionar o servico ao firewald de forma temporaria
  * firewall-cmd --zone=public --add-service=vnc-server  

- Para (re)ler as regras do firewallD:
  * firewall-cmd --reload

- Listar os serviços ativos:
  * firewall-cmd --zone=public --list-all

- Para ativar logs:
  * firewall-cmd --set-log-denied=unicast


```
Testes do serviço TOTVS e Check_MK foi realizado por: 
@Daivid Junior Thomaz, thomazdede(a)yahoo.com.br
https://www.linkedin.com/in/daivid-jr-thomaz-80165797
```
