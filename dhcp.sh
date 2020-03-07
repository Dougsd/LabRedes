#!/usr/bin/env bash
#Douglas Schmitz Dupski
#Configurando servidor dhcp-ipv4 e ipv6
#MENU------------------------------------------------------------------------------------------#
Menu(){
	 
	echo -e '\033[07;32mCONFIGURACOES\033[00;37m##########' 
	echo "[ 1 ] INSTALAR ISC-DHCP-SERVER"
	echo "[ 2 ] INSTALAR RADVD"
	echo "[ 3 ] CONFIGURAR ESCOPO"
	echo "[ 4 ] SELECIONAR INTERFACE"
	echo "[ 0 ] SAIR"
	echo -e '\033[07;31mOPCAO:\033[00;37m' 
	read opcao

	case $opcao in
		1) IscServer ;;
		2) Rad ;;
		3) escopo ;;
		4) Inter ;;
		0) exit ;;
	esac
}

IscServer(){
	apt-get install isc-dhcp-server
	clear
	Menu
}

Rad(){
	apt-get install radvd
	clear
	Menu
}


escopo(){
	#CONFIGURAR IPV4---------------------------------------------------------#
	echo "CONFIGURACAO IPV4:"
	chmod 777 /etc/dhcp/dhcpd.conf
	rm /etc/dhcp/dhcpd.conf
	clear
	echo "INFORME A FAIXA DE IP PARA RESERVAS:"
	echo "INICIO:"
	read inicio
	echo "FIM:"
	read fim
	echo "INFORME A NETMASK:"
	read mascararede
	echo "INFORME A SUBNET:"
	read subrede
	echo "INFORME O ENDERECO GATEWAY:"
	read gateway
	echo "INFORME O ENDERECO DNS:"
	read dns
	echo "INFORME O ENDERECO BROADCAST:"
	read broadcast

	echo '
	### Arquivo de configuração do dhcpdv4 ####

	# Esta é a linha que habilita a atualização dinâmica.
	ddns-update-style none;

	# Controla o tempo de renovação do IP, 600=10Min
	default-lease-time 600;

	# Tempo que a máquina pode usar um determinado IP
	max-lease-time 7200;

	#Indica que o servidor DHCP será autoritário em todo o seguimento da rede; 
	authoritative;

	#Rede a qual se aplica
		subnet '$subrede' netmask '$mascararede' {
		range '$inicio' '$fim';

	#Gateway padrao
		option routers '$gateway';

	#Configuracoes de DNS
		option domain-name-servers '$dns';

	#Endereço Broadcast
		option broadcast-address '$broadcast';

	#Definicao de Horario 18000 = Brasil
		option time-offset -18000;
	}


	#host ws-linux {
	#  hardware ethernet xx:xx:xx:xx:xx:xx;
	#  fixed-address 172.16.1.1;
	#}
	' >>/etc/dhcp/dhcpd.conf
	clear
	#CONFIGURAR IPV6-------------------------------------------------------------------#
	echo "CONFIGURACAO IPV6:"
	chmod 777 /etc/dhcp/dhcpd6.conf
	rm /etc/dhcp/dhcpd6.conf
	clear
	echo "INFORME A FAIXA DE IP PARA RESERVAS:"
	echo "INICIO-ipv6:"
	read inicio6
	echo "FIM-ipv6:"
	read fim6
	echo "INFORME A NETMASK-ipv6:"
	read mascararede6
	echo "INFORME A SUBNET-ipv6:"
	read subrede6
	echo "INFORME O ENDERECO DNS:"
	read dns6


	echo '
	### Arquivo de configuração do dhcpdv6 ###

	# Esta é a linha que habilita a atualização dinâmica
	ddns-update-style none;

	# Controla o tempo de renovação do IP, 600=10Min
	default-lease-time 600;

	# Tempo que a máquina pode usar um determinado IP
	max-lease-time 7200;

	#Indica que o servidor DHCP será autoritário em todo o seguimento da rede
	authoritative;

	#Para registrar mensagens de log
	log-facility local7;

	#Rede a qual se aplica
	subnet6 '$subrede6' {
		
		# Intervalo que sera entregue
		range6 '$inicio6' '$fim6';

		#Configuracoes de DNS
		# option dhcp6.name-servers '$dns6';
		# option dhcp6.domain-search "empresax.com.br";

	}

	#host  ws-linux {
	#	host-identifier option dhcp6.client-id 16:13:00:01:00:01:c1:86:08:00:13:16;
	#	fixed-address6 2001:db8:acad:cafe::faca;
	#	} '>>/etc/dhcp/dhcpd6.conf

#------------------------------------------------------------------------------------------#
	rm /etc/radvd.conf
	echo 'interface '$interface' {
		AdvSendAdvert on;
		AdvManagedFlag on;
		# habilita o recebimentode outras configurações vindas do servidor DHCPv6
		AdvOtherConfigFlag on;
		MinRtrAdvInterval 3;
		MaxRtrAdvInterval 10;

		# Endereço de Rede
		prefix '$subrede6'
		{
			AdvOnLink on;
			# não permite que os clientes se autoconfigurem
			AdvAutonomous off;
			AdvRouterAddr on;
		};
	};' >>/etc/radvd.conf
	clear
	Menu

}
Inter(){
	#CONFIGURANDO O ISC-DHCP-SERVER--------------------------------------------#
	echo "INFORME A INTERFACE QUE DESEJA CONFIGURAR:"
	echo "Para mais de uma interface exem:-> eth0 eth1 ... "
	read interface
	chmod 777 /etc/default/isc-dhcp-server
	rm /etc/default/isc-dhcp-server
	clear
	echo '
	# Defaults for isc-dhcp-server (sourced by /etc/init.d/isc-dhcp-server)

	# Path to dhcpds config file (default: /etc/dhcp/dhcpd.conf).
	#DHCPDv4_CONF=/etc/dhcp/dhcpd.conf
	#DHCPDv6_CONF=/etc/dhcp/dhcpd6.conf

	# Path to dhcpds PID file (default: /var/run/dhcpd.pid).
	#DHCPDv4_PID=/var/run/dhcpd.pid
	#DHCPDv6_PID=/var/run/dhcpd6.pid

	# Additional options to start dhcpd with.
	#	Dont use options -cf or -pf here; use DHCPD_CONF/ DHCPD_PID instead
	#OPTIONS=""

	# On what interfaces should the DHCP server (dhcpd) serve DHCP requests?
	#	Separate multiple interfaces with spaces, e.g. "eth0 eth1".
	INTERFACESv4=''"'$interface'"''
	INTERFACESv6=''"'$interface'"''
	'>>/etc/default/isc-dhcp-server
	clear
	Menu
}
Menu





























#---------------------------------------------------------------------------#


