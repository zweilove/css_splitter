# CssSplitter

## Status

Work in progress of turning this https://gist.github.com/2398394 into a gem.  Not released yet.

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


## Limitations

Currently the gem only supports stylesheets that need to be split into 2 files.  It could theoretically create more splits (e.g. if you should have more than 8190 selectors), but in that case you should probably refactor the stylesheets anyway.  Contact us, if you have this requirement.


## License

This project rocks and uses MIT-LICENSE.