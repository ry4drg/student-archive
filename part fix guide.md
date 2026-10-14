Here is the complete, step-by-step process to move your `/home` directory to `/mnt/storage`. 

This is a safe and common operation, but because you are moving your personal data, it is important to follow the steps carefully.

### ⚠️ Before You Start: Critical Pre-Flight Checklist

1.  **Backup Your Data:** While this process is reliable, a mistake can lead to data loss. If you have critical files, back them up to an external drive or cloud storage first.
2.  **Log Out of Your Desktop:** You cannot move `/home` while you are logged into your graphical desktop. You will need to perform this operation from a **TTY** (text console).
3.  **Have Your Root Password Ready:** You will need `sudo` access.

### Step 1: Switch to a TTY (Text Console)

Press `Ctrl + Alt + F3` on your keyboard. You will be presented with a black screen asking for your login. Log in with your username (`yulian`) and password.

*Note: You might need to try F4, F5, or F6 if F3 doesn't work.*

### Step 2: Prepare the Storage Directory

Your `/mnt/storage` partition is `/dev/sda1`. We need to copy the contents of your current `/home` to a new folder on this drive.

```bash
# Create a new directory on the storage drive for your home files
sudo mkdir /mnt/storage/home
```

### Step 3: Copy Your Home Data

Use `rsync` to copy the data. This is much safer than `cp` because it preserves file ownership, permissions, and hidden files (like your `.config` and `.cache` folders).

```bash
# The -a option preserves permissions, ownership, and timestamps.
# The trailing slash on /home/ is important to copy the *contents*.
sudo rsync -avx /home/ /mnt/storage/home/
```

This may take some time, as you have about 69 GB of data.

### Step 4: Verify the Copy

Once the copy is complete, verify that the sizes match:

```bash
sudo du -sh /home /mnt/storage/home
```

The sizes should be very close (within a few MB). If they match, you can proceed.

### Step 5: Rename the Old Home Directory

We will rename the old `/home` to keep it as a temporary backup. This frees up the `/home` path for the new mount point.

```bash
sudo mv /home /home_old
```

### Step 6: Create the New Mount Point and Mount It

Create a fresh, empty `/home` directory and then temporarily mount the new storage partition to it to test before making it permanent.

```bash
# Create the new empty directory
sudo mkdir /home

# Mount the storage partition to the new /home
sudo mount /dev/sda1 /home
```

### Step 7: Test the Mount

Check if everything is working by listing the contents of your new home:

```bash
ls -la /home
```

You should see your user folder (`yulian`) and all your files. If you do, the mount is successful.

### Step 8: Make It Permanent with /etc/fstab

You need to tell the system to mount this partition at `/home` automatically every time it boots. First, get the UUID of your storage partition:

```bash
sudo blkid /dev/sda1
```

Copy the UUID value (a long string of letters and numbers). Now, edit your fstab file:

```bash
sudo nano /etc/fstab
```

Add this line to the bottom of the file (replace `YOUR-UUID-HERE` with the actual UUID you copied, and remove the quotes):

```
UUID="YOUR-UUID-HERE"  /home  ext4  defaults  0  2
```

Save the file (`Ctrl+O`, then `Enter`) and exit (`Ctrl+X`).

### Step 9: Reboot and Verify

Reboot your computer:

```bash
sudo reboot
```

Once you log back into your graphical desktop, open a terminal and run:

```bash
df -h /home
```

You should now see `/dev/sda1` (or its UUID) mounted at `/home`, with plenty of free space.

### Step 10: Clean Up (Optional)

After you have rebooted successfully and confirmed everything works, you can delete the old backup to reclaim space on your root partition:

```bash
sudo rm -rf /home_old
```

**Wait a few days before doing this**, just in case you discover a setting or file that didn't migrate correctly.
