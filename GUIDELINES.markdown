
## Commit Guidelines ##

Thank you for your pull requests! Please make sure that commits comply with
following guidelines, so that commit messages will self-explanatory and revision
history easy to browse and searchable:

* commit messages should begin with either *verb* in the simple simple past
  tense (try to use only the following verbs: *Added*, *Changed* or
  *Removed*) or *special prefix* in square brackets:
  
    * [FIX] - commit fixes a bug. Message should contain description of the bug.  
      Example: https://github.com/lstejskal/adapi/commit/71f881a85a16a174b2faf86c0ec72d5a490db438

    * [HOTFIX] - commit fixes a bug, but the bugfix is brittle and should be
      improved. Usually this marks a temporary hack which solves an urgent problem.  
      Example: https://github.com/lstejskal/adapi/commit/a28e7d1d8d1a26de7e3a380d7fc8153752250388
  
    * [REFACTOR] - refactoring without any (or very little) changes in functionality.  
      Example: https://github.com/lstejskal/adapi/commit/4eef493857ec0dcb581e88f87c51668c81a97d5d
  
    * [BUNDLER] something to do with gems  
      Example: https://github.com/lstejskal/adapi/commit/a2838281b725ed6d826495683c822fd81807c674
      
    * You can also make create your own custom prefix, but please do it only sparingly.

* commit messages should be as short as possible and to the point. Ideally we
  should be able to figure out what the commit is about just by reading the
  commit message, without a glance into the code.  
  Example: "[FIX] nil.method error in Keyword#find method"

* commits should not be too long, only deal with one thing or a couple of related things

* avoid afterthought commits and last-minute fixes so popular in SVN. You're in the git now: ammend and rebase.

  Example of unnecessary "afterthought" commits:  
  10:00 12345 Added BubbleGum class  
  10:05 12345 [FIX] removed extra comma in BubbleGum class  
  10:15 12345 [REFACTOR] BubbleGum#chew method  

  Last two fixes should be additionaly included to the first commit by `git ammend` command.

## Branch Structure ##

* *stable branch* - `master`, obviously. And also branch with the same name
  as current version of gem. For example: if gem is version 0.0.4, stable branch
  in either `master` and `0-0-4`. `master` branch might also contain latest
  bugfixes from development branch.

* *development branch* - branch with higher number than current gem version;
  there should be always only one such branch. For example, if gem is version
  0.0.4, development branch is `0-0-5`. If you living on the edge is your
  thing, use development branch. It's not stable, but it won't be intentionally
  broken either. It contains latest updates and bugfixes. Bigger features have
  their own branches.

* *feature branch* - named after feature that's being implemented in it. For
  example: `v201109`, where the latest version of AdWords API is implemented.
  Lots of action is happening there, expect things to be broken, use at your own
  risk and make sure you know what you're doing (like, by reading the source
  code first).
