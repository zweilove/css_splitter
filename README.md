# CssSplitter [![Build Status](https://travis-ci.org/zweilove/css_splitter.png?branch=master)](https://travis-ci.org/zweilove/css_splitter) [![Dependency Status](https://gemnasium.com/zweilove/css_splitter.png)](https://gemnasium.com/zweilove/css_splitter)

Gem for splitting up stylesheets that go beyond the IE limit of 4096 selectors, for Rails 3.1+ apps using the Asset Pipeline.  You can read this [blogpost](http://railslove.com/blog/2013/03/08/overcoming-ies-4096-selector-limit-using-the-css-splitter-gem) for an explanation of this gem's background story.


## Installation

Install by putting `gem 'css_splitter'` into your Gemfile.

## What it does?

Older versions of Internet Explorer (version 9 and below) have a hard limit for the number of CSS selectors they can process, which is 4095.  If one of your stylesheets exceeds this limit, all the rule sets beyond the 4095th selector will not be processed by IE and your app will miss some styling information.

CssSplitter integrates with the Rails 3.1+ Asset Pipeline to generate additional split stylesheets with all the CSS rules beyond the 4095th that can be served to IE browsers in order to get all the styling information.


## Dependencies

* Rails 3.1+
* Asset Pipeline

## Documentation

### 1. Splitting your stylesheets

The first step is indentifying the stylesheets that have more than 4095 selectors and therefore need to be split for IE.

Once you know which stylesheets need to be split, you need to create a second "container file" for those stylesheets with the file extension `.split2`, that will contain the styles beyond the 4095 selector limit.

For example, if you want to split `too_big_stylesheet.css`, you need to create a new file `too_big_stylesheet_split2.css.split2` in the same directory.  The only content of that container, will be an include of the original file, e.g.:

    # app/assets/stylesheets/too_big_stylesheet_split2.css.split2

    //= include 'too_big_stylesheet.css'

You also need to remember to add those new files to the asset pipeline, so they will be compiled. For example:

    # config/application.rb

    module MyApp
      class Application < Rails::Application
        config.assets.precompile += %w( too_big_stylesheet_split2.css )

Here is a checklist of requirements for your split stylesheet:

1. It needs to have different filename than orginal, e.g. `original_stylesheet_split2` or `application_split2`
2. It needs to have `.split2` as the terminal file extension, e.g. `.css.split2` or `.css.sass.split2`
3. It needs to include the content of the orginal stylesheet, e.g. through `//= include 'application'`
4. It needs to be added to list of precompiled assets



### 2. Including your split stylesheets

Now that you have split up your big stylesheets at the 4095 limit you need to change your HTML layout, so the split stylesheets are used for older IE versions (IE9 and older).

You can just use our `split_stylesheet_link_tag` helper, which would look something like this:

    # app/views/layout/application.html.erb
    <%= split_stylesheet_link_tag "too_big_stylesheet", :media => "all" %>

    # output
    <link href="/stylesheets/too_big_stylesheet.css" media="screen" rel="stylesheet" type="text/css" />
    <!--[if lte IE 9]>
      <link href="/stylesheets/too_big_stylesheet_split2.css" media="screen" rel="stylesheet" type="text/css" />
    <![endif]-->

Or you can just create similar HTML as in the above example yourself.  If you want to use the `split_stylesheet_link_tag` helper you need to make sure the gem is loaded in production, so you can't put it in the `:assets` group in your Gemfile.

## How it works

Basically, CssSplitter is registering a new `Sprockets::Engine` for the `.split2` file extension, that will fill those files with all the selectors beyond the 4095th.  Unfortunately, those `.split2` files need to be created manually, because we haven't figured out a way for a `Sprockets::Engine` to output multiple files.  They need to present before the compile step.

If you have more questions about how it works, look at the code or contact us.

## Gotchas

#### Having a JS asset with the same name as the the split stylesheet

If you want to split a style (e.g. `assets/stylesheets/application.*`) and have a JS asset with the same name (`assets/javascripts/application.*`) in your asset load_path (as is the default in Rails), you need to include the stylesheet along with the file extension `// = include 'application.css'` because otherwise it will try to include the JS asset of the same name instead.  Sprocket's `= include` directive doesn't seem to differentiate between different types/folders and just takes the first asset it can find for any given name (see #10).

#### Don't use Sprocket's `= require_tree .` for stylesheets

If you require a `.split2` stylesheet in your tree that in turns includes the base stylesheet like shown below, you will end up with a nasty `Sprockets::CircularDependencyError`!

    /* assets/stylesheets/application.css */
    /* = require_tree .
    
    /* assets/stylesheets/application_split2.css.split2 */
    /* = include 'application.css' */

To avoid this it's recommended to **always use Sass's `@import`** for all your stylesheets in favor of Sprocket's `= require` directives, just as the official `sass-rails` gem says: https://github.com/rails/sass-rails#important-note


## Limitations & Known Issues

**More than 8190 selectors**

Currently the gem only supports stylesheets that need to be split into 2 files.  It could theoretically create more splits (e.g. if you should have more than 8190 selectors), but in that case you should probably refactor your stylesheets anyway.  Contact us, if you have this requirement.

**@media queries**

The selector counting algorithm is currently not counting `@media` queries correctly.  For each `@media` query it is adding one additional selector to the count (which is actually not a problem in most cases).

If you have a `@media` query spawning right over the 4096 selector barrier, it will probably get ripped apart into the two splits and ultimately produce broken CSS.  You can either try to move the `@media` queries (e.g. before the 4096 selector barrier) or help us fix this issue.


## Credits & License

This is a joint project by the two German Rails shops [Zweitag](http://zweitag.de) and [Railslove](http://railslove.com), therefore the GitHub name "Zweilove".

The original code was written by [Christian Peters](mailto:christian.peters@zweitag.de) and [Thomas Hollstegge](mailto:thomas.hollstegge@zweitag.de) (see this [Gist](https://gist.github.com/2398394)) and turned into a gem by [Jakob Hilden](mailto:jakobhilden@gmail.com).

This project rocks and uses MIT-LICENSE.
