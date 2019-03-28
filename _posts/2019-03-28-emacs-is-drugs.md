---
layout: post
title: Emacs is drugs
date: 2019-03-28 21:06:19 +0800
category: tools
excerpt: 像上瘾的毒药
comments: true
---

> 每个程序员都会遇到这一天，他要做一个决定，vim还是emacs,还是IDE。

近来一直主要用 Golang, 早已不再年轻的我自然是选择功能强大的 Goland, 日常工作无压力。即使没有免费的注册码了，我也毫不犹豫地买了正版。只是，它太慢了，太卡了，16GB内存的 Mac 跑起来都不轻松。

在无数次的痛苦的等待中，我终于决定换一个 Editor 试一试。 Atom 也慢，Code 看起来都很不错，插件多，界面舒服，速度也快，但我面对它总有一种无所适从的感觉。我偶尔会用它来做些零碎的工作，但从来没法把它当作
一个主要的开发工具。

这几天偶然翻起来一直装在电脑里确很久没有打开的 Emacs, 才明白了 Code 的问题在哪。

Code 是一个优秀的 Editor, 但也仅此而以。我们用它来写代码，代码和 Editor 是两个东西。我们要学习怎么去使用这个软件，这个学习的过程和写代码是两套系统。它像PS,像Word，是一个精巧的软件，是编程的产物。

而 Emacs 不同，它是一个 Editor, 但又和任何的 Editor不同。它即是一个精巧的软件，也是一个操作系统，也是编程本身。

首先，它基于 Elisp 编写，是 lisp 到今天少有的面向大众的软件产品。他的所有扩展也都是 lisp 代码。lisp 良好的可读性能让人很容易理解一个扩展是怎么写出来的，你可以如何修改它，照着它写一个新的。你在用它的时候，能明确地感觉到你在写的代码和编辑器不是分离的两个东西。它不是一个服务于你的黑盒子，而是一个对你透明的软体。你可以随时打开它看看他的内在，修改它，调整它，让他的形态更适用于你的需求。在很多人使用 emacs 的时候，会经常发现，你打开的文件列表经常会有 lisp 代码。好像他们属于一个项目似的。

elisp 主要的功能都是面向文本编辑的，所以它比普通的 editor有更多的概念: 缓冲区/ring buffer/minibuf/mode-line等等。这些概念加起来，造就了最为精准丰富的文本处理和表现系统。无数在其他 editor 无法实现或者很难实现的功能，在这里都可以很容地用代码写出来。是的，就是用 elisp 代码。最终，是 elisp 代码组成了 emacs, 而对其他的 editor 来说，组成他们的是基本功能 + 扩展。

Editor/IDE 的分化，是因为用常规的软件设计思路，无法作出一个满足以下功能的开发工具:

1. 支持所有语言
2. 对特定语言做特定的优化支持
3. 使用简单

IDE 选择了2，3, 对1的支持非常有限，而且必须还是以一两个主要语言为主要支持对象。Code/Atom 这样的 Editor 通过插件选择了1，部分达到2，但无法做到3。觉得使用他们简单的，背后是长时间的不那么愉快的使用，记忆。

Emacs 的独特之处在于，它像 Code,通过插件支持1,2。然后3就看个人的兴趣，如果能跨过 lisp 这一关，一切都非常简单了。

为什么？因为在一个 Editor 中，我们最常需要记忆的几部分是: 快捷键/功能/变量。在其他的 Editor/IDE 中，这些都是需要分别记忆的东西。而且功能越庞杂，要记忆的东西也越多，但在 emacs 中，他们都是 lisp 表达式。lisp 也只有表达式。你需要记录的只是三个快捷键

* 查询一个函数(表达式)的作用
* 查询一个快捷键绑定了什么函数(表达式)
* 查询一个变量的值(表达式)

比如下面的例子，我想知道 f5 这个快捷键是用来干嘛的, 然后输入 `C-h k f5`

![](https://hangyan.github.io/images/posts/emacs/emacs-key-help.png)

Emacs 告诉了我如下信息:

* 这个快捷键绑定了哪个表达式
* 这个表达式的源码所在的文件，可以点击跳转
* 这个表达式的文档，在 lisp , 文档是表达式(函数)的一部分
* 哪些地方引用了这个表达式
* 开启debug/trace的方式
* 表达式的源代码

具体来说，这个快捷键(f5)的作用是打开一个当前项目的文件树：

![](https://hangyan.github.io/images/posts/emacs/emacs-tree.png)

这些信息告诉我们的不只是某个快捷键是干嘛的，而是所有的一切。代码，文档，快捷键，关联，一切都联系在一起，你不用刻意去记忆。因为你会在无数的地方将他们关联起来。关联本身就是记忆。


再比如, 很多时候，我们确实想执行一个功能，比如我想查看当前json文件的结构，你不一定给他绑了快捷键，你也不知道具体的函数名是什么，那么这时候我可以通过`json`进行模糊搜索，来找到可能的表达式:

![](https://hangyan.github.io/images/posts/emacs/emacs-m-x.png)

(如果没有，可以直接用安装 package 的命令来安装相关的 package)

找到了后执行即可，如果它已经绑定了快捷键，Emacs 会在之后给你提示。


在使用 Emacs 的一开始，你记住这几个 help 的命令，之后的一切都顺其自然，无需太过费劲心力了。

写几行代码，改几行lisp。

玩一局俄罗斯方块，煮一杯咖啡。

写几封邮件，读几篇新闻。

下班。

![](https://hangyan.github.io/images/posts/emacs/emacs.png)












