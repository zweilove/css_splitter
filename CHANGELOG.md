# 0.4.2

* [bugfix] correctly split stylesheets even if @keyframes are directly on the rule limit #55 by [@rubenswieringa](https://github.com/rubenswieringa)

# 0.4.1

* [Improvement] All `*_splitN.css` files default to `debug: false` in development to prevent empty file bug.

# 0.4.0

* **Breaking changes!**
* The `CssSplitter::SprocketsEngine` is now registered as a bundle_processor to avoid issues with sprockets directives #29
 * `.split2` extension is no longer necessary/supported, now we rely on `_splitN` at the end of the filename
 * Now you need to use the `require` rather than the `include` directive in the split stylesheet
 * Prohibition against using `require_tree .` and `require_self` directives no longer applies
 * Better tests
 * Thanks a lot to [@Umofomia](https://github.com/Umofomia)
* loosen dependency on `rails` (depend on `sprockets` instead), to make gem compatible to other frameworks like `middleman`

# 0.2.0

* loosen dependency to make it compatible with rails 4

# 0.1.1

* Added license info ("MIT") to gemspec

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
