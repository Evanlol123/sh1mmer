<div align="center">
    <h1>SH1MMER</h1>
    
<h3>
    Shady Hacking 1nstrument Makes Machine Enrollment Retreat
</h3>

<i>
    Website, source tree, and write-up for a ChromeOS enrollment jailbreak
</i>
</div>

## The Fog....

Downgrading and unenrollment has been patched by Google:tm:. If your Chromebook has never updated to version 112 (or newer) before (check in `chrome://version`), then you can ignore this and follow the normal instructions. If not, unenrollment will not work as normal.

If your Chromebook is on version 112 or 113, unenrollment is still possible if you're willing to [disable hardware write protection](https://mrchromebox.tech/#devices). On most devices, this will require you to take off the back of the Chromebook and unplug the battery, or jump two pins. Further instructions are on [the website](https://sh1mmer.me/#fog).

### "Unenrollment" Without Disabling Hardware Write Protection

If you aren't willing to take apart your Chromebook to unenroll, you can use an affiliated project, [E-Halcyon](https://fog.gay) to boot into a deprovisioned environment temporarily.

## What is SH1MMER?

**SH1MMER** is an exploit found in the ChromeOS shim kernel that utilitzes modified RMA factory shims to gain code execution at recovery.<br>

For more info, check out the blog post/writeup [here](https://blog.coolelectronics.me/breaking-cros-2/)

## How does it work?

RMA shims are a factory tool allowing certain authorization functions to be signed, but only
the KERNEL partitions are checked for signatures by the firmware. We can edit the other partitions to our will as long as we remove the forced readonly bit on them.

## How do I use it?

The prebuilt binaries have been taken off of the official mirror ([dl.sh1mmer.me](https://dl.sh1mmer.me)), so you'll have to build it from source.

Here's how you do that.
First, you need to know your Chromebook's board. Go to `chrome://version` on your Chromebook and copy the word after `stable-channel`. If `chrome://version` is blocked, you can search up your Chromebook's model name on [chrome100](https://chrome100.dev) and see what board it corresponds to. **DO NOT DOWNLOAD ANYTHING FROM [chrome100](https://chrome100.dev) AND USE IT WITH THE BUILDER, IT WILL NOT WORK.**

If your board name is in the list below, great! Download the RAW shim corresponding to your board from [here](https://dl.sh1mmer.me).

- (**B**) brask, brya
- (**C**) clapper, coral, corsola
- (**D+E**) dedede, enguarde
- (**G**) glimmer, grunt
- (**H**) hana, hatch
- (**J+K+N**) jacuzzi, kukui, nami
- (**O**) octopus, orco
- (**P+R**) pyro, reks
- (**S**) sentry, stout, strongbad
- (**T+U+V+Z**) tidus, ultima, volteer, zork

If it's not, good luck. You'll have to try and call up your OEM and demand the files from them, which they are most definitely unlikely to give to you.

### Building a Beautiful World Shim

**IMPORTANT!!!!** IF YOU HAVE EITHER THE `coral` OR `hana` BOARDS, OR SOME OTHER OLDER BOARDS (which?), DO NOT FOLLOW THESE INSTRUCTIONS, INSTEAD SKIP TO THE "[Building A Legacy Shim](#building-a-legacy-shim)" SECTION

Now we can start building. Type out all of these commands in the terminal. You need to be on Linux or WSL2 and have the following packages installed: `cgpt`, `git`, `wget`.
Note that WSL doesn't work for some people, and if you have trouble building it it's recommended to just use a VM or the [web builder](https://sh1mmer.me/builder.html)
**WEB BUILDER DOES NOT INCLUDE PAYLOADS!! YOU MUST BUILD IT MANUALLY FROM SOURCE FOR PAYLOADS**

```
git clone https://github.com/MercuryWorkshop/sh1mmer
cd sh1mmer/wax
wget https://dl.sh1mmer.me/build-tools/chromebrew/chromebrew.tar.gz
sudo bash wax.sh /path/to/the/shim/you/downloaded.bin
```

When this finishes, the bin file in the path you provided will have been converted into a **SH1MMER** image. Note that this is a destructive operation, you will need to redownload a fresh shim to try again if it fails.

If you want to build a devshim, replace `chromebrew.tar.gz` with `chromebrew-dev.tar.gz` and add `--dev` to the end of `sudo sh wax.sh /path/to/the/shim/you/downloaded.bin`
Devshim builds will mount a much larger chromebrew partition over `/usr/local`, allowing you to access a desktop environment and even firefox from within sh1mmer. It's what allowed us to [run doom on a shim](https://blog.coolelectronics.me/_astro/doom.82b5613a_Z1LR94C.webp).

To install the built `.bin` file onto an external drive, use the Chromebook Recovery Utility, BalenaEtcher, Rufus, or any other flasher.

### Building a Legacy Shim

The raw shim files for boards such as `HANA` or `CORAL` were built before graphics support was added into the tty. This makes it impossible for the Beautiful World GUI to work and thus a legacy CLI-only shim must be built.

Type out all of these commands in the terminal. You need to be on linux and have the following packages installed: `cgpt`, `git`, `wget`.

Note that the legacy shim **will work on all boards**. The legacy version of wax now supports nano (shrunken) shims!

```
git clone https://github.com/MercuryWorkshop/sh1mmer
cd sh1mmer/wax
sudo bash wax_legacy.sh
```

## CrBug Link

[crbug.com/1394226](https://crbug.com/1394226)

## Credits

- [CoolElectronics](https://discord.com/users/696392247205298207) - Pioneering this wild exploit
- [ULTRA BLUE#1850](https://discord.com/users/904487572301021265) - Testing & discovering how to disable rootfs verification
- [Unciaur](https://discord.com/users/465682780320301077) - Found the inital RMA shim
- [TheMemeSniper](https://discord.com/users/391271835901362198) - Testing
- [Rafflesia](https://discord.com/users/247349845298249728) - Hosting files
- [generic](https://discord.com/users/1052016750486638613) - Hosting alternative file mirror & crypto miner (troll emoji)
- [Bypassi](https://discord.com/users/904829646145720340) - Helped with the website
- [r58Playz#3467](https://discord.com/users/803355425835188224) - Helped us set parts of the shim & made the initial GUI script
- [OlyB](https://discord.com/users/476169716998733834) - Scraped additional shims
- [Sharp_Jack](https://discord.com/users/1006048734708240434) - Created wax & compiled the first shims
- [ember#0377](https://discord.com/users/858866662869958668) - Helped with the website
- Mark - Technical Understanding and Advisory into the ChromeOS ecosystem
