title: Getting Started

---

# Prerequisites

You will need docker to be installed on your machine.

---

# Getting Started with Heighliner

Heighliner is a Ruby Gem. You can install it using

```
gem install heighliner
```

We don't recommend adding it to your bundle files, because Heighliner is more useful as an environment handler than a gem that your program can use.

---

# A Minimal Example

> Do this tutorial to learn Heighliner!

Since Heighliner is meant to be used to improve the dev process of a web app, it makes no sense to go into all the different ways it can be used, so this section is written like a _tutorial_ with a simple example to demonstrate its usage.

This tutorial will show you 3 simple steps to illustrate how to get started with Heighliner. At the end of this tutorial you will be directed to where you can find more detailed topics about how to use Heighliner

## 1. Start with a folder

First of all, create a directory called `hello`

```
mkdir hello
```

And enter it

```
cd hello
```

## 2. Make a simple app

In order to use this you need a Steerfile and a Dockerfile at the very least. 

For this very simple example lets make an extremely simple application that serves `Hello Heighliner`. In order to do this, we just have to create a Dockerfile containing the following:

```
touch Dockerfile
```

```
# Dockerfile
FROM public.ecr.aws/degica/barcelona-hello

RUN echo 'Hello Heighliner' > /var/www/static/index.html
```

The `public.ecr.aws/degica/barcelona-hello` image is a simple image that contains just an nginx server and a fileserver that serves out of `/var/www/static/` in the container. You can find its source code here: https://github.com/degica/barcelona-hello

And then we create a Steerfile

```
touch Steerfile
```

```
# Steerfile
dockerfile 'Dockerfile'

expose '8080'
```

## 3. Start up the App

Now we initialize Heighliner. We do this with the `heighliner init` command. This command takes one parameter called the environment name, and it is stored in a configuration file in `$HOME/.heighliner/config.yml` so it is global to your user.

This allows Heighliner to set up some data required to start your environment. This only needs to be done once. If you want to throw this environment away, you can call `heighliner deinit`

```
heighliner init hello
```

In this case, we call our environment `hello`. This is also important as it will be the prefix for the DNS name that will be used for this. In this case by default, setting the environment name to `hello` makes the URL for the app `http://hello.lvm.me`

Having done that, we can start up the program using:

```
heighliner up -av
```

And you should be able to go to `http://hello.lvm.me` and find a page that displays the text `Hello Heighliner`

## That's all, folks!

Congratulations for getting to the end of the tutorial for Heighliner! Obviously you would want to find out more!

To find out about how you would provide this application with a database, check out [Databases](/0130-databases).

To find out how to set up HTTPS on your server, go to [Suffixes](/0140-suffixes).

To find out more about setting up environment variables, and other features, go to [Steerfile](/0120-the-steerfile)

---

## Useful Commands

### Run stuff in the container

You can run stuff inside your container by going

```sh
bundle exec heighliner login sh
```

And you can do anything inside the container.

If you need root,

```sh
bundle exec heighliner root sh
```

### Attach to the container

If you want to run with the container in the foreground simply go

```sh
bundle exec heighliner attach
```

This is similar to `heighliner login` but it terminates the running container, whereas `heighliner login` will simply run you in the same container as the running container.

```sh
bundle exec heighliner attach nano /etc/hosts
```

### Save database state

```sh
bundle exec heighliner db_save customer_setup
```

You can also save your database state to a file in your current dir:

```sh
bundle exec heighliner db_save ./my_setup.dbimage
```

### Load database state

```sh
bundle exec heighliner db_load customer_setup
```

You can load a previously saved database file that you have

```sh
bundle exec heighliner db_load ./my_setup.dbimage
```

### Get ports

Heighliner decides what ports to use on the host. To know them simply go

```sh
bundle exec heighliner show ports
```

### Curious?

You can see what Heighliner is doing under the hood with the `-v` flag:

```sh
bundle exec heighliner -v db_reset 
```
