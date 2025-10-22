Usage:
chmod +x chkpbkp.sh
./chkpbkp.sh

Will leave a $HOSTNAME-$DATE.tgz file as output, with subdirectories for each VS. It will disregard Virtual Switches and Routers.
When run on a non-VSX platform, it creates only a VS0 folder.
