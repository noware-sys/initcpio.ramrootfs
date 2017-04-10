#!/bin/bash

fs_type=$(stat --format=%T --file-system /)

HOME="/etc/unison/home"
#echo ">"$HOME"<"
# s="${2-8}"
#home="/root"
unison="/etc/unison/default"
unison_temp="/etc/unison/temp"
items=( "dev" "proc" "run" "sys" "tmp" "mnt" )

case "${fs_type}" in
	tmpfs | ramfs )
		# The original root:
		source="/root_source"
		# The current RAM disk root:
		temporary="/root_ram"
		#disk="/mnt/disk"
		#ram="/mnt/ram"
		#ram="/"
		
		#unison "${disk}" "${ram}" -times -backuploc local -fastcheck false -batch -ignore "Path {dev}" -ignore "Path {proc}" -ignore "Path {run}" -ignore "Path {sys}" -ignore "Path {tmp}" -ignore "Path {swap.sys}" -ignore "Path {media}" -ignore "Path {mnt}" -ignore "Path {misc}" -ignore "Path {net}" -ignore "Path {disk}" -ignore "Path {ram}" -ignore "Path {new_root}" -ignore "Path {new-root}" -ignore "Path {old_root}" -ignore "Path {old-root}" -ignore "Path {var/log/journal}" -force "${ram}" -confirmbigdel=false -confirmmerge=false -log=false
		#unison "${disk}" "${ram}" -times -backuploc local -fastcheck false -batch -ignore "Path {dev,proc,run,sys,tmp,swap.sys,media,mnt,misc,net,rootfs,rootfs-source,media/bricks/rootfs*,disk,ram,new[_-]root,old[_-]root,var/log/journal}" -force "${ram}" -confirmbigdel=false -confirmmerge=false -log=false
		#systemctl stop ramfs.service
		
		#umount "${disk}"
		#umount --recursive /
		;;
	# glusterfs:
	fuseblk )
		source="/media/bricks/rootfs"
		temporary="/media/bricks/rootfs-ram"
		;;
	* )
		fs_valid=0
esac

# "${source}" should be a mountpoint; otherwise, it means that we are copying back to RAM.
if ! mountpoint --quiet "${source}"
then
	#echo "YES 1"
	
	fs_valid=0
	
# Try to determine if the source seems to be a valid root file system.
elif test "${fs_valid}" != "0"
then
	#echo "YES 2"
	
	for item in "${items[@]}"
	do
		#echo "${source}"/"${item}"
		
		if ! test -d "${source}"/"${item}"
		then
			#echo "YES 3"
			
			fs_valid=0
			break
		fi
	done
fi

#echo $fs_valid

# Cannot synchronize back to the source if there is none available. It may have been unmounted before reaching this point.
if test "${fs_valid}" != "0"
then
	#echo "YES 4"
	
	export HOME
	
#	if ! test -d "${source}""${unison}"
#	then
#		mkdir --parents "${source}""${unison}"
#	fi
	
	#if ! test -d "${unison_temp}"
	#then
		#mkdir --parents "${unison_temp}" "${HOME}"
		mkdir --parents "${HOME}" "${unison}" "${unison_temp}"
	#fi
	
	#unset HOME
	
	UNISON="${unison}"
	export UNISON
	
	#unison "${source}" "${temporary}" -times -backuploc local -xferbycopying -fastcheck false -batch -ignore "Path {dev,proc,run,sys,tmp,swap.sys,media,mnt,misc,net,{old,new}[_-]root,var/log/journal,""${source#/}"",""${temporary#/}"",""${unison#/}"",""${unison_temp#/}"",""${HOME#/}""}" -force "${temporary}" -confirmbigdel=false -confirmmerge=false -log=false
	unison "${source}" "${temporary}" -times -backuploc local -xferbycopying -fastcheck false -batch -ignore "Path {dev,proc,run,sys,tmp,swap.sys,media,mnt,misc,net,{old,new}[_-]root,var/log/journal,""${source#/}"",""${temporary#/}"",""${unison_temp#/}""}" -force "${temporary}" -confirmbigdel=false -confirmmerge=false -log=false
	
	if test "${1}" != "0"
	then
		#sleep 5
		#exit
		
		# Synchronize the meta data:
		#unset UNISON
		#HOME="${home}"
		#export HOME
		UNISON="${unison_temp}"
		export UNISON
		#unison "${source}""${unison}" "${temporary}""${unison}" -times -backuploc local -xferbycopying -fastcheck false -batch -ignore "Path {""${UNISON#/}"",""${HOME#/}""}" -force "${temporary}""${unison}" -confirmbigdel=false -confirmmerge=false -log=false
		unison "${source}""${unison}" "${temporary}""${unison}" -times -backuploc local -xferbycopying -fastcheck false -batch -force "${temporary}""${unison}" -confirmbigdel=false -confirmmerge=false -log=false
	fi
	
	#sleep "${s}"
	
	#umount --all-targets --recursive "${source}"
fi
