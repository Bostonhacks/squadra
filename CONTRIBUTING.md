# Adding yourself to Squadra

## Things you will need

* Linux, Mac OS X, or Windows.
* git (used for source version control).
* An ssh client (used to authenticate with GitHub).

## Getting the code and configuring your environment

* Ensure all the dependencies described in the previous section are installed.
* Fork `https://github.com/Bostonhacks/squadra` into your own GitHub account. If
   you already have a fork, and are now installing a development environment on
   a new machine, make sure you've updated your fork so that you don't use stale
   configuration options from long ago.
* If you haven't configured your machine with an SSH key that's known to github, then
   follow [GitHub's directions](https://help.github.com/articles/generating-ssh-keys/)
   to generate an SSH key.
* `git clone git@github.com:<your_name_here>/squadra.git`
* `git remote add upstream git@github.com:Bostonhacks/squadra.git` (So that you
   fetch from the master repository, not your clone, when running `git fetch`
   et al.)

## Adding yourself

We gladly accept additions via GitHub pull requests.

To start adding yourself:

 * `git fetch upstream`
 * `git checkout upstream/master -b <name_of_your_branch>`
 *  Modify team.yml to include your information!
 * `git commit -a -m "<your informative commit message>"`
 * `git push origin <name_of_your_branch>`

To send us a pull request:

* `git pull-request` (if you are using [Hub](http://github.com/github/hub/)) or
  go to `https://github.com/Bostonhacks/squadra` and click the
  "Compare & pull request" button
