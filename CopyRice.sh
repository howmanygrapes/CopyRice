#!/bin/bash


day=$(date +%F%H%M)
temp=/tmp/tmp_backups
backup=$HOME/RiceBackups
dirs=(
    Pictures
    Documents
    .config
    Desktop
)
# Setup
if mkdir -p "$backup" "$temp" "$backup/Rice$day"; then
    echo "Setup comlete, starting backup..."
else
    echo "Setup failed."
    exit 1
fi

# Creates Backup
for dir in "${dirs[@]}"; do
    tar -cf - "$HOME/$dir" \
        | pv -s $(du -sb "$HOME/$dir" | awk '{print $1}') \
        | gzip > "$temp/backup_$dir.$day.tar.gz"
done
    
mv $temp/*.tar.gz $backup/Rice$day && echo "Backup complete. Saved to $backup" || echo "Backup failed."
    rm -r $temp

 read -p "Would you like to backup to an external drive? (yes/no ) " yn

case $yn in 
    yes ) echo Getting list of available drives...;;
    no ) echo exiting...;
        exit;;
    * ) echo invalid responce;
        exit 1;;
esac

#Search and list storage devices
drives=( $(df | grep '/dev/sd' | awk '{print $6}') )

#Select storage device menu
select drive in "${drives[@]}" none; do
    [ "$drive" = "none" ] && exit 
    [ -w "$drive" ] && break || echo "Can't write to $drive"
done
echo "Saving backup to $drive"  

 cp -r $backup/Rice$day $drive & PID=$! 

echo "THIS MAY TAKE A MINUTE..."
printf "["
# While process is running...
while kill -0 $PID 2> /dev/null; do 
    printf  "▓"
    sleep 1
done
printf "] done!"


