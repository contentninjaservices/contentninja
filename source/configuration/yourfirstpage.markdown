---
layout: jasonlong
title: "Your First Page"
date: 2015-04-11 00:00:00
author: John Smith
profile: 107224552229621877852
published: true
---

## Create file for your first page

Create the directory "source" a new file "index.markdown" with the following content:

    ---
    layout: default
    title: "Your First Page"
    date: 2015-04-11 00:00:00
    author: John Smith
    profile: 107224552229621877852
    published: true
    ---
    
    ## header H2 
    
    text text text usw. 

The first part between the two "---" is the header of a page. So things like Title, Date, etc. set.

With the "layout" is defined which layout is used. Thus, the appropriate layout file is loaded from the "source/_layout". More on that later.

"published" can be set to true or false. New files can thus be set to not be published. The page can thus be neugeniert without this page is published with. Is on one side of a fault can also disable it so, and only turn back online after the correction.

The parameter "profile" indicates the Google+ Profiles of the author. Is specified in the template one side author may be associated with it. This causes the image of the author in the results on a Google search will be displayed.

All other parameters in the header part are self-explanatory and need not be further described.

The content area is described later. Then the Formateirungsmöglichkeiten in Markdown be described.

Next step is the [layout](/configuration/layout.html).

