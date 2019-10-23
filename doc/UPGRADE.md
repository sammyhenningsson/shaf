## Upgrading a project created with shaf version < 1.1.0
Important: Always perform upgrades on a clean slate (e.g. run `git stash|commit`) before you start an upgrade.

Shaf continuously keeps inproving and sometimes that means introducing changes that are not backward compatible with previous versions. This means that if you created your Shaf project with an older version of this gem and then upgrade Shaf to the latest version, your project might break. To fix this you, (from inside your project directory) will need run the `upgrade` command.
```sh
cd /path/to/my_project
shaf upgrade
```
Note: The upgrade command will try to apply patches to extisting files. Firstly, this requires the `patch` command to be installed (shouldn't be a problem for most distros). More importantly, if a patch does not succeed, then some manual processing is required. When a patch is rejected the `.orig` and `.rej` files contains the file content before applying the patch resp. the patches that failed to be applied. Please apply all patches in the `.rej` files manually then delete the all `.orig` and `.rej` files. (Sometimes a patch succeed, but with a different line offset than expected, then a `.orig` file is created but no `.rej` file. This is normally fine and it should be safe to just remove the `.orig` file.)  
After all patches has been applied manually, then continue the upgrade by running the `upgrade` command again.

Version 1.2.0 extracts the database config from `config/database.rb` into `config/database.yml`. Upgrading to version 1.2.0 will add the new versions of these files as `config/database.rb.new` and `config/database.yml.new`. Make sure to update the yml file with your database config and then rename both files by dropping the `.new` suffix. This will overwrite the old `config/database.rb`, which should no longer be needed. (Note: `config/database.yml` will be processed through erb, so using environment variables is still possible) 

Version 1.1.0 uses a few new features from the `hal_presenter` gem, So, make sure to update `hal_presenter` to version 1.2.1 or later.
```sh
bundle update hal_presenter
```
