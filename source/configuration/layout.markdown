---
layout: jasonlong
title: "Layout files"
date: 2015-04-11 00:00:00
author: John Smith
profile: 107224552229621877852
published: true
---

## The layout files

The layout files are in the directory "source/_layout". Here is an example "default.html":
    
    { % include head.html %}
    </head>
    <body>
    <div id="top">
      <div id="header">
        { % include menu.html %}
        <div id="wrap">
          <img src="/images/content-top.gif" alt="content top" class="content-wrap" />
          <div id="content">
            <div id="main">
              <div class="blog-index">
                <div class="new_post" itemprop="mainContentOfPage" itemtype="http://schema.org/Article" itemscope="" >
                  { % content %}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    </body>
    </html>

### Includes 

In the first row of the HTML header is loaded via include. This includes are located in the directory "source/_include". Includes can load other includes.
In head.html will include, for example, "css/screen.css". The "css/screen.css" is also stored in the directory "source/_include".

Furthermore, code in default.html normal HTML. In between is still a inlude the navigation area of the page.

In the section "your first page" when a header file Markdown for Content Ninja is described. 

### Replace content and other variables

The second part is the content part of a page. The part that is visible on the page later.
This area will be inserted here. And is at the location of the { % content %}.

### The layout from pages

Includes also be used for the layout of content. In the header of a page is the parameter "layout: default.html". This file is loaded from the include folder.

Here layout of our content areas:

    <h3 class="title"><a href="{{ posturl }}" title="screen und git">{{ title }}</a></h3>
    <div class="postcontent">
      <div class="entry-content">
        {% content %}
        <br /> <br />
      </div>
    </div>
    <div class="post_info">
      <time datetime="{{ postdate }}" pubdate data-updated="true"></time> {{ postdate }}
    </div>

This part is currently still a little confusing. Internal are the two variables "content" used. 
When you generate a page is the content of a page loaded in content and then replaced in the include directory for layout instead of content.
The result is stored. But then inserted in the entire page layout and content also means again. 
That will change in a future version and then makes it easier to understand.




