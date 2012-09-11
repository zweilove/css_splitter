# CssSplitter

### Status

Work in progress of turning this https://gist.github.com/2398394 into a gem.  Not release yet.

## Dependencies

* Rails 3.1+
* Asset Pipeline

## Documentation

In order to include both parts of the split stylesheet for IE browsers you can use the following helper:

    # helper
    split_stylesheet_link_tag("too_big_stylesheet")

    # which will output
    <link href="/path/too_big_stylesheet.css" media="screen" rel="stylesheet" type="text/css" />
    <link href="/path/too_big_stylesheet_part2.css" media="screen" rel="stylesheet" type="text/css" />


This project rocks and uses MIT-LICENSE.