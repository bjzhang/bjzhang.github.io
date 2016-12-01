---
layout: post
title: Analysis a hang in openSUSE Leap 42.2
categories: [Linux]
tags: [openSUSE, kde, jbd2, file index]
---

I use openSUSE as my work distro in recent years. In the early this week, I upgrade my old openSUSE 13.1(which is not maintained anymore) to openSUSE Leap 42.2. According to suggestion, I upgrade through DVD and one version one time. I upgrade through openSUSE 13.2, openSUSE Leap 42.1 to openSUSE Leap 42.2.

After upgrade, the GUI of 42.2 is very cool.
TODO screenshot.

But I feel the hang when I use it. At first, I though it is because I use kernel-default. I want to switch to kernel-desktop, I found that it is not provided by default. So, I install the kernel-desktop from home:Ladest. The situation is not improve it after that.

Usually, it just part of UI is hang. E.g. hang in a window of tmux. And other part looks good.
And it is easy to reproduce by open a file through vim and exit. It will hang in open or exit.

I use strace to trace it.

Wang nan and I  investigate investigate why the system in hung so frequently. Before ask help from nan, I already know the other is a hung in the air, open all your mask, but I think it's how is in the mask, which is wrong. Nice dance that you spoke to talk to, or proper records gun eight to know the Hot point. But there is actually no unusual hot point, in the systems. So, one use the last race to tracing the, beam, we found that it will how, in the. In order to understand what that is a process doing, weak at the stake in the park health systems. We found that no matter the hall in the enter of film was a exit of him, the house isn't you to the gym eighty two, lock. So we use that respond to trace the. We found that, there are several colors of the two, first first one is the kid iii were x eleven, the second one is win, and third one is the, move or extract. Then I google the ball fell structure I found that a is, some sort of hung, issues in it. And the index, it created is about three game bites. We decided to disable it, in tomorrow and see whether it is, okay, I also suspect that it is because, phil season is almost full, the index of the amount point is about only two big bags, left. It's just index, half of the old files. Okay, one thousand, me, index and it only finished about, four hundred thousand. So I grew up the file same systems tonight, and I will try suspense index, in my daily work and enable it after my, go home.
