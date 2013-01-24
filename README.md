# CssSplitter [![Build Status](https://travis-ci.org/zweilove/css_splitter.png?branch=master)](https://travis-ci.org/zweilove/css_splitter) [![Dependency Status](https://gemnasium.com/zweilove/css_splitter.png)](https://gemnasium.com/zweilove/css_splitter)

Gem for splitting up stylesheets that go beyond the IE limit of 4095 selectors, for Rails 3.1+ apps using the Asset Pipeline.

## Status

Work in progress of turning this https://gist.github.com/2398394 into a gem.  We are at version `0.0.2` and a bunch of bugs have already been fixed.  But there are probably still edge cases left where it won't work perfectly, yet.

Contributions in form of bug reports, test cases and pull requests are welcome!


## Installation

Install by putting `gem 'css_splitter'` into your Gemfile.

## What it does?

Older versions of Internet Explorer (basically version 9 and below) have a hard limit for the number of CSS selectors they can process, which is 4095.  If one of your stylesheets exceeds this limit, all the rule sets beyond the 4095th selector will not be processed by IE and your app will miss some styling information.

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

    //= include 'too_big_stylesheet'

You also need to remember to add those new files to the asset pipeline, so they will be compiled. For example:

    # config/application.rb

    module MyApp
      class Application < Rails::Application
        config.assets.precompile += %w( too_big_stylesheet_split2.css )

So, these are the 4 important requirements for your splitted stylesheet:

1. needs to have different filename than orginal, e.g. `original_stylesheet_split2` or `application_split2`
2. needs to add `.split2` as the terminal file extension, e.g. `.css.split2` or `.css.sass.split2`
3. needs to include the content of the orginal stylesheet, e.g. through `//= include 'application'`
4. neess to be added to list of precompiled assets



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

Or you can just create similar HTML as in the above example yourself.

## How it works

Basically, CssSplitter is registering a new `Sprockets::Engine` for the `.split2` file extension, that will fill those files with all the selectors beyond the 4095th.  Unfortunately, those `.split2` files need to be created manually, because we haven't figured out a way for a `Sprockets::Engine` to output multiple files.  They need to present before the compile step.

If you have more questions about how it works, look at the code or contact us.


## Limitations & Known Issues

**More than 8190 selectors***

Currently the gem only supports stylesheets that need to be split into 2 files.  It could theoretically create more splits (e.g. if you should have more than 8190 selectors), but in that case you should probably refactor your stylesheets anyway.  Contact us, if you have this requirement.

**@edia queries**

The selector counting algorithm is currently not counting `@media` queries correctly.  For each `@media` query it is adding one additional selector to the count (which is actually not a problem in most cases).

If you have a `@media` query spawning right over the 4096 selector barrier, it will probably get ripped apart into the two splits and ultimately produce broken CSS.  You can either try to move the `@media` queries (e.g. before the 4096 selector barrier) or help us fix this issue.


## Credits & License

This is a joint project by the two German Rails shops [Zweitag](http://zweitag.de) and [Railslove](http://railslove.com), therefore the GitHub name "Zweilove".

The original code was written by [Christian Peters](mailto:christian.peters@zweitag.de) and [Thomas Hollstegge](mailto:thomas.hollstegge@zweitag.de) (see this [Gist](https://gist.github.com/2398394)) and turned into a gem by [Jakob Hilden](mailto:jakobhilden@gmail.com).

This project rocks and uses MIT-LICENSE.
