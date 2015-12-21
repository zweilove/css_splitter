# CssSplitter [![Build Status](https://travis-ci.org/zweilove/css_splitter.png?branch=master)](https://travis-ci.org/zweilove/css_splitter)

Gem for splitting up stylesheets that go beyond the IE limit of 4096 selectors, for Rails 3.1+ apps using the Asset Pipeline.  You can read this [blogpost](http://railslove.com/blog/2013/03/08/overcoming-ies-4096-selector-limit-using-the-css-splitter-gem) for an explanation of this gem's background story.

### Development status

Since the original developers of this gem are not actively using it in any project at the moment, it is currently in **limited maintenance** mode.  Issues are read and pull requests will be reviewed and merged, but there is currently no acitve maintenance/development.

If you are an active user of the gem and would be able to help out maintaining it, it would be greatly appreciated.  Just look at the current issues/pull requests.

## Installation

Install by putting `gem 'css_splitter'` into your Gemfile.

## What it does?

Older versions of Internet Explorer (version 9 and below) have a hard limit for the number of CSS selectors they can process, which is 4095.  If one of your stylesheets exceeds this limit, all the rule sets beyond the 4095th selector will not be processed by IE and your app will miss some styling information.

CssSplitter integrates with the Rails 3.1+ Asset Pipeline to generate additional split stylesheets with all the CSS rules beyond the 4095th that can be served to IE browsers in order to get all the styling information.


## Dependencies

* Sprockets 2.0+
* e.g. Rails 3.1+ with the asset pipeline

## Documentation

### 1. Splitting your stylesheets

The first step is identifying the stylesheets that have more than 4095 selectors and therefore need to be split for IE.

Once you know which stylesheets need to be split, you need to create a second "container file" for those stylesheets with the `_split2` suffix appended to the base filename that will contain the styles beyond the 4095 selector limit.  The extension of this file should be just `.css` without any additional preprocessor extensions.

For example, if you want to split `too_big_stylesheet.css.scss`, you need to create a new file `too_big_stylesheet_split2.css` in the same directory.  The only content of that container, will contain a `require` directive to the name of the original asset, e.g.:

    # app/assets/stylesheets/too_big_stylesheet_split2.css

    /*
     *= require 'too_big_stylesheet'
     */

If your stylesheet is big enough to need splitting into more than two more files, simply create additional `_split3`, `_split4`, etc. files, the contents of which should be identical to the `_split2` file.

You also need to remember to add those new files to the asset pipeline, so they will be compiled. For example:

    # config/application.rb

    module MyApp
      class Application < Rails::Application
        config.assets.precompile += %w( too_big_stylesheet_split2.css )

Here is a checklist of requirements for your split stylesheet:

1. It needs to have the `_splitN` suffix appended to the original asset name, e.g. `original_stylesheet_split2` or `application_split2`
2. It needs to have `.css` as a file extension.
3. It needs to require the orginal stylesheet.
4. It needs to be added to list of precompiled assets.

### 2. Including your split stylesheets

Now that you have split up your big stylesheets at the 4095 limit you need to change your HTML layout, so the split stylesheets are used for older IE versions (IE9 and older).

You can just use our `split_stylesheet_link_tag` helper, which would look something like this:

    # app/views/layout/application.html.erb
    <%= split_stylesheet_link_tag "too_big_stylesheet", :media => "all" %>

    # output
    <link href="/stylesheets/too_big_stylesheet.css" media="all" rel="stylesheet" type="text/css" />
    <!--[if lte IE 9]>
      <link href="/stylesheets/too_big_stylesheet_split2.css" media="all" rel="stylesheet" type="text/css" />
    <![endif]-->

If your stylesheet is split into more than two files, add the `split_count` option to specify the total number of files.

    <%= split_stylesheet_link_tag "too_big_stylesheet", :split_count => 3 %>

Or you can just create similar HTML as in the above example yourself.  If you want to use the `split_stylesheet_link_tag` helper you need to make sure the gem is loaded in production, so you can't put it in the `:assets` group in your Gemfile.

## How it works

Basically, CssSplitter is registering a new Sprockets bundle processor that looks for CSS assets named with the `_splitN` suffix and will fill those files with all the selectors beyond the 4095th.  Unfortunately, those `_splitN` files need to be created manually, because we haven't figured out a way for a `Sprockets::Engine` to output multiple files.  They need to present before the compile step.

If you have more questions about how it works, look at the code or contact us.

## Gotchas

#### Differences from previous versions

Note that if you used versions below `0.4.0` of this gem, the naming and contents of the split files have changed. Split files no longer need to have the `.split2` extension and now use the `require` directive rather than the `include` directive. The previous prohibition against using `require_tree .` and `require_self` directives also no longer applies.  For more details see the [CHANGELOG.md](CHANGELOG.md#040)

#### Empty *_split2.css file

Since 0.4.1 in development split stylesheets have `debug: false` option by default. This prevents the empty `*_split2.css` file issue. You can always explicitly go one way or the other setting `debug` option directly in the `split_stylesheet_link_tag` like this:

```
<%= split_stylesheet_link_tag "application", debug: false %>
```

## Credits & License

This is a joint project by the two German Rails shops [Zweitag](http://zweitag.de) and [Railslove](http://railslove.com), therefore the GitHub name "Zweilove".

The original code was written by [Christian Peters](mailto:christian.peters@zweitag.de) and [Thomas Hollstegge](mailto:thomas.hollstegge@zweitag.de) (see this [Gist](https://gist.github.com/2398394)) and turned into a gem by [Jakob Hilden](mailto:jakobhilden@gmail.com).

**Major Contributors**

* [@Umofomia](https://github.com/Umofomia)
* [@kruszczynski](https://github.com/kruszczynski)

This project rocks and uses MIT-LICENSE.

