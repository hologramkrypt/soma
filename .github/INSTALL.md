### The Arch Linux installation process:

* * *

```
1. Download ISO from the [official arch linux website](https://archlinux.org/).
 2. Use a tool like [Rufus](https://rufus.ie/en/), or [Balena Etcher](https://etcher.balena.io/) to flash the ISO onto a flashdrive.
 3. Turn off your PC, insert the USB, and enter your BIOS settings. 
 4. Boot using the flashdrive.
```

> If you have a hard wired connection, continue on. See Network Configuration if you're using WiFi.

```
1. Run `*archinstall*`.
 2. Choose your install configuration. See [recommended install configuration]().
 3. See [Configuration](#Getting-things-set-up).
```




***

### Getting things set up:

##### Required applications:

##### Recommended applications:

###### Recommended install configuration:


***

### Network Configuration:

During the \[arch linux install\](#The Arch Linux installation process:), you need a stable internet connection. Most errors during installation stem from this small problem.

### Connect to the internet

> At the root prompt, run:
> 
> `systemctl restart iwd`  
> `iwctl`
> 
> Inside iwctl:
> 
> `device list` (note your wireless device, e.g., wlan0)  
> `station wlan0 scan`  
> `station wlan0 get-networks`  
> `station wlan0 connect "<SSID>"` (enter passphrase if prompted)
> 
> Exit iwctl, then:
> 
> `exit`  
> `ping -c 3 archlinux.org` (verify connection)

***

~ During the arch install, I would recommend using [NetworkManager](https://wiki.archlinux.org/title/NetworkManager) for your network protocol. ~

