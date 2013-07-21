# 0.1.0

* [Removal] Removed unused `Splitter#split` method
* [Bugfix] Fixed little bug in `Splitter#count_selectors` that was yielding wrong results
* [Bugfix] Removed unnecessary files in `app/` which were causing #13 and #17

# 0.0.2

* [Improvement] Made the SprocketEngine addition an initializer, so it will work even when `initialize_on_precompile` isn't set
* [Bugfix] Removed unnecessary charset extraction from `Splitter#count_selectors` method, which had caused the first rule of the stylesheet to be ignored.
* [Bugfix] Fixed/refactored charset extraction, so that it doesn't overwrite the first rule of the stylesheet anymore.
* [Bugfix] Fixed `Splitter#strip_comments` method, so it doesn't mess with protocol agnostic URLs (e.g. `url(//assets.myserver.com/asset.png)`) anymore and only strips valid CSS comments #5

# 0.0.1

Initial commit