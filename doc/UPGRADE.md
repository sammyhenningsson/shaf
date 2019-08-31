## Upgrading a project created with shaf version < 1.1.0
Important: Always perform upgrades on a clean slate (e.g. run `git stash|commit`) before you start an upgrade.

The latest version of Shaf introduced a few changes that are not backward compatible with previous versions. This means that if you created your Shaf project with an older version of this gem and then upgrade this gem to the latest version, your project will not function. To remedy this you, (from inside your project directory) will need to execute
```sh
cd /path/to/my_project
shaf upgrade
```
Note: The upgrade command will try to apply patches to extisting files. Firstly, this requires the `patch` command to be installed (shouldn't be a problem for most distros). More importantly, if a patch does not succeed, then some manual processing is needed. When a patch is rejected the `.orig` and `.rej` files contains the file content before applying the patch resp. the patches that failed to be applied. Please apply all patches in the `.rej` files manually then delete the all `.orig` and `.rej` files. (Sometimes a patch succeed, but with a different line offset than expected, then a `.orig` file is created but no `.rej` file. This is normally fine and it should be safe to just remove the `.orig` file.)

Version 1.1.0 uses a few new features from the `hal_presenter` gem, So, make sure to update `hal_presenter` to version 1.2.1 or later.
```sh
bundle update hal_presenter
```
