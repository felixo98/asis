# Por defecto todo lo que entra y pasa por el router es rechazado.
iptables -F
iptables -F 
iptables -P INPUT DROP
iptables -P FORWARD DROP                                                        
# Habilitar ip forwarding.
echo 1 > /proc/sys/net/ipv4/ip_forward                                          
# Se configura las direcciones con las que se sale hacia el NAT.
iptables -a POSTROUTING -s 192.168.2.0/24 -o enp0s3 -j MASQUERADE
iptables -a POSTROUTING -s 192.168.4.0/24 -o enp0s3 -j MASQUERADE
iptables -a POSTROUTING -s 192.168.3.0/24 -o enp0s3 -j MASQUERADE               
# Se deja pasar el tráfico de la red interna y los pings de respuesta del Host.
iptables -A FORWARD -i enp0s8 -p icmp --icmp-type 0 -j ACCEPT
iptables -A FORWARD -i enp0s3 -p all -j ACCEPT
iptables -A FORWARD -i enp0s9 -p all -j ACCEPT
iptables -A FORWARD -i enp0s10 -p all -j ACCEPT


                                                                                 
# Se deja pasar el tráfico de la red interna a debian1 y se deja pasar a los pings de respuesta del Host.

iptables -A INPUT -i enp0s8 -p icmp --icmp-type 0 -j ACCEPT
iptables -A INPUT -i enp0s3 -p all -j ACCEPT
iptables -A INPUT -i enp0s9 -p all -j ACCEPT
iptables -A INPUT -i enp0s10 -p all -j ACCEPT
iptables -A INPUT -i lo -p all -j ACCEPT    

#ssh
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 22 -j DNAT --to 192.168.4.2:22
iptables -A FORWARD -d 192.168.4.2 -p tcp --dport 22 -j ACCEPT
#server http
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 80 -j DNAT --to 192.168.2.2:80
iptables -A FORWARD -d 192.168.2.2 -p tcp --dport 80 -j ACCEPT
#server https
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 443 -j DNAT --to 192.168.2.2:443
iptables -A FORWARD -d 192.168.2.2 -p tcp --dport 443 -j ACCEPT
                                                      
            

# Todo lo que sale al extranet tiene la ip de debian1

iptables -t nat -A POSTROUTING -o enp0s8 -j SNAT --to 192.168.56.10
# Establecer camino a la red interna 3.
ip route add 192.168.4.0/24 via 192.168.3.2 dev enp0s10 
