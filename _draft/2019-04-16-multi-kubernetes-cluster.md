---
layout: post
title: 多 Kubernetes 集群相关项目
date: 2019-04-16 11:43:03 +0800
tags: Kubernetes
excerpt: 
comments: true
---

* TOC
{:toc}

## sample-apiserver

> [https://github.com/kubernetes/sample-apiserver](https://github.com/kubernetes/sample-apiserver)

接近于`CRD`，但是更为灵活。适合于自定义资源的逻辑处理。也可以用来做一个与 Kubernetes 具有相似风格的 Web Service。
通常用于自定义资源，与 kubernetes apiserver 一起工作


## kube-aggregator

> [https://github.com/kubernetes/kube-aggregator](https://github.com/kubernetes/kube-aggregator)

内置于 kubernetes apiserver, 用于链接上面所说的 sample-apiserver 与 kubernetes apiserver 一起工作


