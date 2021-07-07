# CW2 - Firearms: Source 2 Base Expansion
[Steam Workshop addon](https://steamcommunity.com/sharedfiles/filedetails/?id=2527824716)
This is a base expansion to the Customizable Weaponry 2 (CW2) SWEP base. It aims to exist alongside the original SWEPs without being a base overhaul or rewrite.

I wrote this to add a bunch of functionality for the FA:S 2 SWEPs and to give other developers who are still using CW2 some new capabilities. Where possible, I used the hooks instead of copying over and reimplementing functions. I chose to do this in order to:

1. Save myself the trouble of maintaining more code to be in line with the original base
2. Promote better compatability with the other rewrites on the Workshop (CWC, etc.)

Some of it is probably a mess, with mixed function cases, scope pyramids, etc. I've tried to clean it up as I added features.

## Organization
The `lua` folder is most relevant for addon developers.  

Under this, the `cw_fas2` folder has miscellaneous scripts that run before the main weapon base is loaded.

The extra weapon functionality itself is split into a couple of files under `weapons/cw_fas2_base`. There should be enough documentation to figure stuff out if you need to override something for a new SWEP.
