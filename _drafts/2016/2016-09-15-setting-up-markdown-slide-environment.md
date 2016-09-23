---
layout: post
title: Wrote slide through markdown
categories: [Software]
tags: [slide, markdown, css, remark]
---

Recently, I try to write the slide through markdown. There are different ways to generate the pdf slide from markdown.

Pandoc and beamer
-----------------
The first method I know is pandoc. Pandoc is a useful software which support lots of formats. The beamer of pandoc is a tools which could convert markdown to pdf. [Tinylab](wwww.tinylab.org) provide the container, user could easily convert through the container.
But I am really not familar with Latax. It is hard for me to get the expected format.
Reference the following [documents](http://tinylab.org/write-documents-with-markdown-lab/)(Sorry it is Chinese) for details.

Remark and decktape
-------------------
Another way is that convert markdown to html and then convert html to pdf.
I used the first part to show the slide in my company. But this is time, I need upload the slide to the website of linuxcon europe which only accept the pdf format.

I also encounter lots of css issue for get the proper format.
E.g. When I download a template from internet, I found that such template could not get the correct multi-level list in markdown. In the end, I found that it is because unneeded "margin" and "padding" is used for body, content, ul and ol.

## Install mardown-to-slides
I do not use remark directly. In fact, I do not know remark when I use [markdown-to-slides](https://github.com/partageit/markdown-to-slides). It is a tool written by nodejs which use remark in the box.
```
npm install -g markdown-to-slides
```
If you npm is lower than 1.4, you may need to upgrade it:
```
npm install -g npm
```

This tools is very easy to use. In the help content, it will display the style and template used by default. You could copy and change it by yourself.
```
> markdown-to-slides -h
markdown-to-slides v1.0.3

Usage: markdown-to-slides file.md

Options:
  --title, -t           Generated page title
  --style, -s           Path to custom stylesheet                                                      [default: "/usr/lib/node_modules/markdown-to-slides/template/style.css"]
  --script, -j          Path to custom javascript
  --template, -l        Path to custom mustache template                                               [default: "/usr/lib/node_modules/markdown-to-slides/template/template.html"]
  --help, -h            This screen
  --output-file, -o     Path to output file (stdout if not specified)
  --document-mode, -d   Generate slides from a document without slide separators (---) or annotations  [boolean]
  --watch, -w           Watch mode                                                                     [boolean]
  --level               Heading level to use as new slides (for example 3 is ###)                      [default: 3]
  --include-remark, -i  Include Remark sources (around 850kB) into the generated document              [boolean]
```

A good enhancement for remark is the document mode which make life easier if you want to show the slide while keep a document. The command I used is:
```
> markdown-to-slides -d -s remark-template.css --template  template.html your.md -o your.html
16:16:59: "your.md" written in "your.html"
```

The line start with "???"  is note which will be ignored in slide.

Reference my [document](https://github.com/bjzhang/bjzhang.github.io/blob/master/_drafts/2016/ILP32_syscall_unit_test_linuxcon_europe.md) for details.

## Using [remark](remarkjs.com)
Remark is one of the famous framework to show the markdown slide in html. It is a standalone html which make people easy to copy and distribute.

Refernce the <remarkjs.com> to understand how to use it. `wget remarkjs.com` will get the index.html which is the result of markdown to slide.

## Using [decktape](https://github.com/astefanutti/decktape) to convert html to pdf
Decktape release its 1.0.0 in 23, Sep. Just follow the instruction in the website
> ./phantomjs decktape.js remark ../../bjzhang.github.io/_drafts/2016/ILP32_syscall_unit_test_linuxcon_europe.html ../../bjzhang
.github.io/_drafts/2016/ILP32_syscall_unit_test_linuxcon_europe.pdf
Loading page ../../bjzhang.github.io/_drafts/2016/ILP32_syscall_unit_test_linuxcon_europe.html ...
Loading page finished with status: success
Remark JS DeckTape plugin activated
Printing slide #41      (41/41) ...
Printed 41 slides


Issue in chromebook
----------
## "/usr/bin/env: node: No such file or directory"
https://github.com/nodejs/node-v0.x-archive/issues/3911
cd /usr/bin
ln -sf nodejs node

# the properties
https://github.com/gnab/remark/wiki/Markdown#slide-properties

