---
layout: post
title: Kubernetes 笔记
date: 2017-08-18
excerpt: "关于Kubernetes的一些零碎笔记"
tags: [kubernetes, desgin, api]
comments: true
category: cloud
redirect_from:
    - /2017/08/18/kubernetes-note.html
---


* TOC
{:toc}


# API

## 声明式的API

声明式： 结果是什么
命令式: 做什么

声明式的操作，相对于命令式操作，对于重复操作的效果是稳定的，这对于容易出现数据丢失或重复的分布式环境来说是很重要的。另外，声明式操作更容易被用户使用，可以使系统向用户隐藏实现的细节，隐藏实现的细节的同时，也就保留了系统未来持续优化的可能性

kubernetes里的API都是声明式,我们描述好自己想要的resource object,kubernetes就会不断尝试去保证这个resource object按我们期望的方式存在.


## API Response

一般包含三部分

* metadata: 元数据
    * annotations: 一些元信息.给第工具用来存储和解析原信息用的.
    * labels: act as filter
    * namespace: resource所处的namespace
    * name: resource名字
    * uuid: 唯一标识
    * creationTimestamp: 创建时间
    * deletionTimestamp: 计划删除的时间(graceful deletion)
    * resourceVersion: 每个resource的内部版本,可以用来确定是否发生了变化.也用于做并发控制
    * generation 
* spec: 具体描述,不同resource的属性不同。spec里通过声明式的方式表明了期望的目标状态
* status: resource的当前状态

下面以展示一下kubernetes node api的metadata作为样例:

**metadata**:

```yaml
metadata:
  annotations:
    flannel.alpha.coreos.com/backend-data: '{"VtepMAC":"9a:98:da:a1:b9:5d"}'
    flannel.alpha.coreos.com/backend-type: vxlan
    flannel.alpha.coreos.com/kube-subnet-manager: "true"
    flannel.alpha.coreos.com/public-ip: 172.18.0.4
    scheduler.alpha.kubernetes.io/taints: '[]'
    volumes.kubernetes.io/controller-managed-attach-detach: "true"
  creationTimestamp: 2017-07-13T09:45:11Z
  labels:
    beta.kubernetes.io/arch: amd64
    beta.kubernetes.io/os: linux
    ip: 172.18.0.4
    kubeadm.alpha.kubernetes.io/role: master
    kubernetes.io/hostname: 172.18.0.4
  name: 172.18.0.4
  resourceVersion: "3785002"
  selfLink: /api/v1/nodes172.18.0.4
  uid: f6fc3022-67af-11e7-b171-0017fa013946
```


可以看到flannel用它来存储了一些自己需要的信息.



这种区分几乎适用于REST架构中的大多数resource.好处:
* 比一整个大的body结构清晰
* 模块化,每个部分的更新迭代不会影响整个body的结构
* 展示及处理方便


## 错误处理
kubernetes的错误情况下的response也遵循上面相同的结构.示例如下:

```json
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "pods \"grafana\" not found",
  "reason": "NotFound",
  "details": {
    "name": "grafana",
    "kind": "pods"
  },
  "code": 404
}
```

其特点是同时提供了机器可读(`reason`)以及人类可读(`message`)的消息. `reason`是对http status code的一种细化.



## Resource Version
上面所说metadata中的`resourceVersion`字段被Kubernets用来做并发控制,在更新一个object前,会去检查它的resourceVersion的值与之前存的值是否匹配,如果不匹配,则会抛出一个`StatusConflict`(http 409).



## Version
一般来说REST API都会要求有一个版本的概念,这样在架构迭代以及功能升级时可以用不同的版本来区分,保证语义及结构清晰.Kubernetes做的更多,它也会用version来区分功能的成熟度(alpha,beta...)

* alpha
    * 可能包含bug,默认关闭,不保证兼容性,适合测试使用
* beta
    * 大方向不会变,细节上可能会有修改.如果有不兼容的改动发生,会提供升级方式
* stable
    * 可稳定使用


## API Group
API分组,一般API都会分为核心的对Resource进行操作的API以及其他零碎的API.

一般URL格式为: `GROUP/VERSION`.GROUP的名字建议的格式为domin name的格式,比如:
`widget.mycompany.com`    


## Runtime config
kubernets支持非常多的参数(已经有很多人在网上吐槽了..),结合上面的版本以及分组,kube-api有很多参数可以用来调控这些.比如禁掉一些Group,禁掉一些Version的API.一个完全可插拔的API Server.


## REGEX
详细定义好各个resource name的`REGEX`要求,比如`namespace`,`service`中不能有点(`.`),只能小写(DNS兼容).

## 字段格式
像date,timestamp等这种字段要保证在所有API中使用用一种格式

## PATCH与PUT
一般来说PUT应该发送resource的整个描述去replace.PATCH只发送需要更新的部分.但一般的场景中遵循此规则的应该不多,大多是只用一个PUT,即用于整个更新也用于部分更新.

kubernetes做的更多,在PATCH操作,它支持几种不同的操作语义

* Json Patch: Content-Type: application/json-patch+json
    * 定义了需要做的操作,示例如下:
        * `{"op": "add", "path": "/a/b/c", "value": [ "foo", "bar" ]}`
    
* Merge Patch: Content-Type: application/merge-patch+jso
    * objects类的是合并,lists类的是replace
* Strategic Merge Patch: Content-Type: application/strategic-merge-patch+json
    * 支持各种自定义操作的patch


# Events
时间也是系统设计里非常重要的一环.发生了上面,什么时间,谁操作的,结果是什么,不仅可以用系统内部问题的排查,也可以作为产品提供给其他用户.

Kubernetes对一些重复性的时间做了累积,原本需要重复显示N次的事件现在用一个计数器来代替.这样可以减少数据存储和系统负载.


# 交互


## 输出

Unix有一个非常出名的设计哲学:"一切皆文件",其优势在于，利用管道及其他工具，无数的小工具(`find`,`grep`,`awk`)等可以方便地协作以完成非常复杂的任务。各个工具均支持`plain text`作为输入以及输出。当然一切皆文件也有一个坏处，开源软件由不同的人写就，没有文本格式的约束，不同的工具均需要一定的文本格式的要求。工具越多，格式也越杂乱，需要人为记忆的东西也越多。例如很多service类工具的配置文件格式的差异，不同命令输出的差异等等

kubernetes由很多组件构成，提供API的服务，命令行的访问工具(`kubetctl`)等等。类似于`docker cli`及`docker daemon`，`kubectl`也是从`kube-api-server`来读取信息展示给用户。我觉得kubetcl做的比较好的一点就是，它将数据的内部结构和展示二者分开了。示例如下:

获取节点的简单信息，不加任何参数:

```bash
[root@172 alauda]# kubectl get no
NAME         STATUS         AGE
172.18.0.4   Ready,master   38d
[root@172 alauda]#
```

指定输出yaml格式的详情

```yaml
...
spec:
  externalID: 172.18.0.4
  podCIDR: 10.1.0.0/24
  providerID: azure:////2882C846-5C01-BE47-B19A-4C5DB5F26348
status:
  addresses:
  - address: 172.18.0.4
    type: LegacyHostIP
  - address: 172.18.0.4
    type: InternalIP
  - address: 172.18.0.4
    type: Hostname
  allocatable:
    alpha.kubernetes.io/nvidia-gpu: "0"
    cpu: "16"
    memory: 57710432Ki
    pods: "110"
...
```


指定输出json格式的详情

```json
{
    "apiVersion": "v1",
    "kind": "Node",
    "metadata": {
        "annotations": {
            "flannel.alpha.coreos.com/backend-data": "{\"VtepMAC\":\"9a:98:da:a1:b9:5d\"}",
            "flannel.alpha.coreos.com/backend-type": "vxlan",
            "flannel.alpha.coreos.com/kube-subnet-manager": "true",
            "flannel.alpha.coreos.com/public-ip": "172.18.0.4",
            "scheduler.alpha.kubernetes.io/taints": "[]",
            "volumes.kubernetes.io/controller-managed-attach-detach": "true"
        },
        "creationTimestamp": "2017-07-13T09:45:11Z",
        "labels": {
            "beta.kubernetes.io/arch": "amd64",
            "beta.kubernetes.io/os": "linux",
            "ip": "172.18.0.4",
            "kubeadm.alpha.kubernetes.io/role": "master",
            "kubernetes.io/hostname": "172.18.0.4"
        },
        "name": "172.18.0.4",
        "resourceVersion": "3785243",
        "selfLink": "/api/v1/nodes172.18.0.4",
        "uid": "f6fc3022-67af-11e7-b171-0017fa013946"
    },
    "spec": {
        "externalID": "172.18.0.4",
        "podCIDR": "10.1.0.0/24",
        "providerID": "azure:////2882C846-5C01-BE47-B19A-4C5DB5F26348"
    },
    "....": "...."
}
```


默认的输出格式比较类似于linux上`ls`的默认输出。但也可以通过指定参数获取json或yaml格式的信息。前者适用于展示，后者适用于处理(管道).`ls`的输出目前既用于展示，也会用于输出。鉴于json目前的流行程度及简洁性，设想plan9上这些小工具均内置于对json或者yaml的支持，那么在利用管道及其他工具做数据处理的时候会大为简便，并且不易出错。


## 输入
kubectl支持从一个描述文件里创建一个resource(yaml或json格式).因为API结构的一致,kubernetes里面几乎所有的资源都可以通过一个`kubectl create -f`来创建出来. 因为每种resource都有大体相同的结构:
Kind,Version,Spec等等
