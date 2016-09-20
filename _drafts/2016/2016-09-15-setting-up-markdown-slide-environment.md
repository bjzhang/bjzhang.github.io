---
layout: post
title: Wrote slide through markdown
categories: [Software]
tags: [slide, markdown, css, remark]
---

Recently, I try to write the slide through markdown. There are different ways to generate the pdf slide from markdown.
The first method I know is pandoc. Pandoc is a useful software which support lots of formats. The beamer of pandoc is a tools which could convert markdown to pdf. [Tinylab](wwww.tinylab.org) provide the container, user could easily convert through the container.
But I am really not familar with Latax. It is hard for me to get the expected format.
Reference the following [documents](http://tinylab.org/write-documents-with-markdown-lab/)(Sorry it is Chinese) for details.

Another way is that convert markdown to html and then convert html to pdf.
I used the first part to show the slide in my company. But this is time, I need upload the slide to the website of linuxcon europe which only accept the pdf format.

I also encounter lots of css issue for get the proper format.



# chromebook
## "/usr/bin/env: node: No such file or directory"
https://github.com/nodejs/node-v0.x-archive/issues/3911
cd /usr/bin
ln -sf nodejs node

# the properties
https://github.com/gnab/remark/wiki/Markdown#slide-properties
