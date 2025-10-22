#!/bin/env bash
# Function to copy files to avoid repetition
files_copy() {
	cp $FWDIR/conf/trac_client_1.ttm $1/.
	cp /etc/udev/rules.d/00-os-XX.rules $1/.
	cp $CVPNDIR/conf/cvpnd.C $1/.
	cp $FWDIR/boot/modules/fwkern.conf $1/.
	cp $FWDIR/conf/cpha_bond_ls_config.conf $1/.
	cp $FWDIR/conf/cpha_specific_vlan_data.conf $1/.
	cp $FWDIR/conf/discntd.if $1/.
	cp $FWDIR/conf/fw_fast_accel_export_configuration.conf $1/.
	cp $FWDIR/conf/fwaffinity.conf $1/.
	cp $FWDIR/conf/fwauthd.conf $1/.
	cp $FWDIR/conf/hsm_configuration.C $1/.
	cp $FWDIR/conf/identity_broker.C $1/.
	cp $FWDIR/conf/ipassignment.conf $1/.
	cp $FWDIR/conf/local.arp $1/.
	cp $FWDIR/conf/malware_config $1/.
	cp $FWDIR/conf/prioq.conf $1/.
	cp $FWDIR/conf/rad_conf.C $1/.
	cp $FWDIR/conf/synatk.conf $1/.
	cp $FWDIR/conf/te.conf $1/.
	cp $FWDIR/conf/thresholds.conf $1/.
	cp $FWDIR/conf/trac_client_1.ttm $1/.
	cp $FWDIR/conf/vsaffinity_exception.conf $1/.
	cp $PPKDIR/conf/simkern.conf $1/.
	cp /var/ace/sdconf.rec $1/.
	cp /var/ace/sdopts.rec $1/.
}

# Will write as VS0, regardless of VSX status

vsid=0
directory=/var/tmp/backup_"$HOSTNAME"_"$(date +%Y-%m-%d)"

mkdir -p $directory/VS$vsid

echo "===========VS$vsid===========" > $directory/VS$vsid/showConf.txt
clish -c "show configuration" >> $directory/VS$vsid/showConf.txt
files_copy $directory/VS$vsid/

# Used in the for loop
clishScript=$(mktemp)
# This fails if not VSX, so works as an implicit check
for i in `vsx stat -v | grep " S "| awk '{print $1}'| grep '^[0-9]' | sort -n -k1,1` # Magic to get VS numbers
do
	vsid=$i
	if [[ $vsid =~ '^[0-9]*$' ]];then shift;else vsid=0;fi

	mkdir -p $directory/VS$vsid
	echo "==========VS$i============" >> $directory/VS$vsid/showConf.txt
	echo "set virtual-system ${vsid}" >${clishScript} # We write commands to a single file, then pass that to clish
	echo "show configuration" >>${clishScript}
	clish -f "${clishScript}" | sed -E 's/^Processing .+?\r//g' >> $directory/VS$vsid/showConf.txt
	files_copy $directory/VS$vsid
done

# Clean up. Beware of the directories should you modify them. We don't want to rm -rf the / directory...
rm "${clishScript}"
tar cf backup_"$HOSTNAME"_"$(date +%Y-%m-%d)".tgz -C $directory .
rm -rf $directory