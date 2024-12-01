set -x
counter=1
file=/home/adam/11.zip
file_name=$(basename "$file")
name="${file_name%.zip}"

printf "%s\n" "$name"

unzip -P "infected" "$file" -d /mnt/vmshare1/
mv /mnt/vmshare1/* /mnt/vmshare1/malware.exe

sudo virsh -c qemu:///system snapshot-revert VM1_Win11 PoweredOffState_VM1_Script4
sudo virsh -c qemu:///system start VM1_Win11
# virt-viewer VM1_Win11

vnet_interface=$(virsh domiflist win11 | awk '/vnet/ {print $1}')
echo "$vnet_interface"
sleep 30 # startup 

vnet_interface=$(virsh domiflist win11 | awk '/vnet/ {print $1}')
echo "$vnet_interface"

echo "started vnet interface collection"
tcpdump -i "$vnet_interface" -nn -XX -vvv -w "/media/bccc-abhay/G_RAID/Malware_Database/Mal_PcapFiles/Backdoor/${counter}_Backdoor_${name}.pcap" & pid=$!

sleep 400 #3 min for UTG.ps1 autoscript which runs at 10:02:00AM

echo "started memory dump"
mkdir /home/adam/dumps/${name}
virsh -c qemu:///system dump --memory-only VM1_Win11 "/home/adam/dumps/${name}/${name}.vmem"

sleep 120 #2 min after memory capture we switchoff the tcpdump
kill $pid
echo "killed tcpdump"

virsh -c qemu:///system shutdown VM1_Win11
sleep 60

virsh -c qemu:///system snapshot-revert VM1_Win11 PoweredOffState_VM1_Script4
mv /mnt/vmshare1/* /home/adam/dumps/${name}
rm -r /mnt/vmshare1/*

# rm -r /mnt/vmshare1/*
# sleep 120
