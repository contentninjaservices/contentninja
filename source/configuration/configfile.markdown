---
layout: jasonlong
title: "Configuration"
date: 2015-04-11 00:00:00
author: John Smith
profile: 107224552229621877852
published: true
---

## Configuration file

The Content Ninja configuration files named: ninja.config. 

    remoteurl = http://www.example.com
    localurl = http://localhost
    
    site.title = Page Title
    site.author = John Smith
    site.email = mail@example.com
    post.title post.content
    site.url = http://www.example.com
    
    default_index = source/index.markdown
    comtec = 1
    
    bin	= /Users/rpr/bin
    lib	= /Users/rpr/bin/lib
    
    source = source
    posts	=	_posts
    drafts = _drafts
    stash	= _stash
    public = output
    
    debug = 0


## Detail information for the configfile

Some parameters of the config file is not currently being used. 
Content Ninja arose initially as blog software. 
The blog part was removed, the once only pure websites with content Ninja could be created.
The blog part is added after a cleanup of the source code again.

The following parameters are currently unused.

   * post.title post.content
   * comtec
   * bin
   * lib 
   * posts
   * drafts
   * stash


### remoteurl

    remoteurl = http://www.example.com

Content Ninja can copy the finished website via ssh or rsync to a server. 
For this purpose, remoteUrl and localurl used to switch between live and test page.

### localurl

    localurl = http://localhost

Content Ninja can copy the finished website via ssh or rsync to a server. 
For this purpose, remoteUrl and localurl used to switch between live and test page.

### site.title 

    site.title = Page Title

Set the page Title in head or can replaced in templates.

Template: 

    {% site.title %}

### site.author 

    site.author = John Smith

Set the Author in the header and can replaced in templates.

Template: 

    {% site.title %}

### site.email

    site.email = mail@example.com

Set the email in the header and can replaced in templates.

Template: 

    {% site.email %}

### post.title post.content

Unused. Used by disabled Blog engine. 

### site.url 

    site.url = http://www.example.com

Set the Page URL in the header and can replaced in templates.

Template: 

    {% site.url %}

### default_index 

    default_index = source/index.markdown

The default index page. This is the first page that visitors see when they do not provide a direct path behind the URL.

s currently not used and enabled in a future version.

### comtec 

    comtac = 0|1 

comtec stands for: CommentTec, a commentary system for content ninja. 
Since Content Ninja static page generated can enable comments with services like Disqus. 
ComTec is a comment system which emerged as the comments should be on your own server. 
In addition, the visitor accesses are not stored on the server from another vendor and recorded.

ComTec was independently programmed and is not included in Content Ninja. 
This can also be used with other blog systems.
In the future Comtec is also published. It is not yet clear when.

### bin	

Unused. 

    bin = /path/to/bin

### lib	

Unused. 

    lin = /path/to/lib 

### source 

This directory contains a javascript, stylesheet, your pages etc.

For further information, read the documentation at: your first page and on.

    source = source 

### posts	

Unused. Blog Part :) 

    posts = _posts 

### drafts 

Unused. Blog Part :) 

    drafts = _drafts

### stash	

Unused. Blog Part :) 

    stash	= _stash

### debug 

    debug = 0|1

if debug = 1 is set to debug issues when generating pages.

Currently, only runtime values printed to check where the content Ninja generate very long takes.
If you write your own modules should be set to 1 when debug test.



